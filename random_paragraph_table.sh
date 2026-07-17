#!/bin/bash
# Cách dùng: ./random_paragraph_table.sh "<tên list>"
#   vd:      ./random_paragraph_table.sh "Batch 1"
#
# Tạo 1 Google Task List mới với tên truyền vào, chọn ngẫu nhiên 1 folder (trừ
# .claude và các folder ẩn khác), chọn ngẫu nhiên 1 file paragraph-*.md trong
# folder đó, tìm bảng (table) trong file đó, convert bảng thành 1 array, rồi
# tạo 1 Google Task cho mỗi dòng dữ liệu trong bảng vào list mới đó:
#   - title: câu tiếng Anh
#   - notes : phiên âm IPA, xuống dòng "####################" để che nghĩa
#             tiếng Việt (không cho đoán được ngay khi mới mở task), rồi đến
#             nghĩa tiếng Việt
#
# Cấu trúc 1 file paragraph chuẩn:
#   dòng 1: đoạn văn tiếng Anh gốc
#   dòng 2: dòng trống (ngăn cách đoạn văn với bảng)
#   dòng 3+: bảng markdown (header, dòng phân cách, các dòng dữ liệu)
#
# Đọc biến môi trường từ file .env (cùng thư mục với script) nếu có, thay vì phải
# export tay mỗi lần. File .env KHÔNG được commit lên git (xem .gitignore).
# Copy .env.example thành .env rồi điền GOOGLE_ACCESS_TOKEN thật vào đó.
#
# Tương thích bash 3.2 (mặc định trên macOS) — không dùng mapfile/readarray.
# Cần có: curl, jq.

set -uo pipefail

TASKLIST_TITLE="${1:-}"
if [[ -z "$TASKLIST_TITLE" ]]; then
    echo "Cách dùng: $0 \"<tên list>\"" >&2
    echo "Ví dụ    : $0 \"Batch 1\"" >&2
    exit 1
fi

# Luôn thao tác từ thư mục chứa script này, bất kể được gọi từ đâu.
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$BASE_DIR" || exit 1

if [[ -f "$BASE_DIR/.env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "$BASE_DIR/.env"
    set +a
fi

if [[ -z "${GOOGLE_ACCESS_TOKEN:-}" ]]; then
    echo "Lỗi: chưa có GOOGLE_ACCESS_TOKEN." >&2
    echo "Tạo file .env (copy từ .env.example) và điền access token vào đó," >&2
    echo "hoặc export GOOGLE_ACCESS_TOKEN=\"<access_token>\" trước khi chạy." >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "Lỗi: cần cài jq để encode JSON an toàn (brew install jq)." >&2
    exit 1
fi

LISTS_URL="https://tasks.googleapis.com/tasks/v1/users/@me/lists"

# ---------- Bước 0: tạo Google Task List mới với tên truyền vào ----------
list_payload="$(jq -n --arg title "$TASKLIST_TITLE" '{title: $title}')"
list_resp_file="$(mktemp)"
trap 'rm -f "$list_resp_file"' EXIT

list_http_code="$(curl -s -o "$list_resp_file" -w '%{http_code}' -X POST "$LISTS_URL" \
    -H "Authorization: Bearer ${GOOGLE_ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$list_payload")"

if [[ "$list_http_code" != "200" && "$list_http_code" != "201" ]]; then
    echo "Lỗi: tạo task list \"$TASKLIST_TITLE\" thất bại (HTTP $list_http_code)." >&2
    sed 's/^/    /' "$list_resp_file" >&2
    exit 1
fi

TASKLIST_ID="$(jq -r '.id' "$list_resp_file")"
if [[ -z "$TASKLIST_ID" || "$TASKLIST_ID" == "null" ]]; then
    echo "Lỗi: không lấy được id của task list vừa tạo." >&2
    sed 's/^/    /' "$list_resp_file" >&2
    exit 1
fi

echo "Đã tạo task list \"$TASKLIST_TITLE\" (id: $TASKLIST_ID)"
echo

API_URL="https://tasks.googleapis.com/tasks/v1/lists/${TASKLIST_ID}/tasks"

# ---------- Bước 1: liệt kê các folder, loại trừ folder ẩn (vd .claude) ----------
folders=()
for d in */; do
    d="${d%/}"
    [[ "$d" == .* ]] && continue
    folders+=("$d")
done

if [[ ${#folders[@]} -eq 0 ]]; then
    echo "Không tìm thấy folder nào (ngoài .claude)." >&2
    exit 1
fi

# ---------- Bước 2: chọn ngẫu nhiên 1 folder có chứa file paragraph-*.md ----------
random_folder=""
files=()
attempts=0
max_attempts=${#folders[@]}

while [[ $attempts -lt $max_attempts ]]; do
    candidate="${folders[$RANDOM % ${#folders[@]}]}"
    candidate_files=()
    for f in "$candidate"/paragraph-*.md; do
        [[ -e "$f" ]] || continue
        candidate_files+=("$f")
    done
    if [[ ${#candidate_files[@]} -gt 0 ]]; then
        random_folder="$candidate"
        files=("${candidate_files[@]}")
        break
    fi
    attempts=$((attempts + 1))
done

if [[ -z "$random_folder" ]]; then
    echo "Không có folder nào chứa file paragraph-*.md." >&2
    exit 1
fi

# ---------- Bước 3: chọn ngẫu nhiên 1 file paragraph trong folder đó ----------
random_file="${files[$RANDOM % ${#files[@]}]}"

echo "Folder đã chọn : $random_folder"
echo "File đã chọn   : $random_file"
echo

# ---------- Bước 4: tách bảng (table) ra khỏi đoạn văn ----------
# File gồm các block phân cách bởi dòng trống (paragraph mode của awk).
# Block cuối cùng chính là bảng.
table_block="$(awk 'BEGIN{RS=""} {block=$0} END{print block}' "$random_file")"

# ---------- Bước 5: convert bảng thành 1 array (mỗi dòng 1 phần tử) ----------
table_array=()
while IFS= read -r line; do
    [[ "$line" == \|* ]] || continue
    table_array+=("$line")
done <<< "$table_block"

if [[ ${#table_array[@]} -eq 0 ]]; then
    echo "Không tìm thấy bảng trong file này." >&2
    exit 1
fi

# ---------- Hàm trim khoảng trắng đầu/cuối (thuần bash, không cần sed) ----------
trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

# ---------- Bước 6: với mỗi dòng dữ liệu trong bảng, tạo 1 Google Task ----------
echo "Bảng có ${#table_array[@]} dòng (kể cả header + dòng phân cách)."
echo "Bắt đầu tạo task lên Google Tasks (list: $TASKLIST_ID)..."
echo "----------------------------------------------------------------"

created=0
failed=0
resp_file="$(mktemp)"
trap 'rm -f "$list_resp_file" "$resp_file"' EXIT

# Delay giữa các lần gọi API để tránh bị Google Tasks coi là spam khi tạo
# hàng loạt task liên tiếp (bảng thường có hơn 100 dòng). Có thể chỉnh qua
# biến môi trường TASK_CREATE_DELAY_SEC (đơn vị giây, hỗ trợ số thập phân).
DELAY_SEC="${TASK_CREATE_DELAY_SEC:-0.3}"

for row in "${table_array[@]}"; do
    # Bỏ qua dòng header và dòng phân cách của markdown table
    [[ "$row" == "| Cụm từ tiếng Anh"* ]] && continue
    [[ "$row" =~ ^[\|\-]+$ ]] && continue

    IFS='|' read -r _ eng ipa vi _ <<< "$row"
    eng="$(trim "$eng")"
    ipa="$(trim "$ipa")"
    vi="$(trim "$vi")"

    [[ -z "$eng" ]] && continue

    mask="####################"
    notes="$ipa"$'\n'"$mask"$'\n'"$vi"

    payload="$(jq -n --arg title "$eng" --arg notes "$notes" '{title: $title, notes: $notes}')"

    http_code="$(curl -s -o "$resp_file" -w '%{http_code}' -X POST "$API_URL" \
        -H "Authorization: Bearer ${GOOGLE_ACCESS_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "$payload")"

    if [[ "$http_code" == "200" || "$http_code" == "201" ]]; then
        created=$((created + 1))
        echo "[OK] $eng"
    else
        failed=$((failed + 1))
        echo "[FAIL $http_code] $eng"
        sed 's/^/    /' "$resp_file" >&2
    fi

    sleep "$DELAY_SEC"
done

echo "----------------------------------------------------------------"
echo "Hoàn tất: $created task tạo thành công, $failed thất bại."
