#!/bin/bash
# Cách dùng: ./check_phrase_length.sh <đường-dẫn-file>
#   vd:      ./check_phrase_length.sh 1-tron-ares-2025/paragraph-2.md
#
# Rà một file paragraph-*.md, tìm bảng cụm từ (cột "Cụm từ tiếng Anh" | "Phiên
# âm IPA" | "Nghĩa tiếng Việt"), rồi liệt kê các dòng có cụm từ tiếng Anh (cột
# 1) quá dài theo quy tắc độ dài trong skill phrase-breakdown-table (mục 3-4):
#   - Quá dài: từ 9 từ trở lên (chuẩn là 3-4 từ, tối đa 8 từ).
#
# Tương thích bash 3.2 (mặc định trên macOS).

set -uo pipefail

FILE="${1:-}"
if [[ -z "$FILE" ]]; then
    echo "Cách dùng: $0 <đường-dẫn-file>" >&2
    exit 1
fi

if [[ ! -f "$FILE" ]]; then
    echo "Lỗi: không tìm thấy file \"$FILE\"." >&2
    exit 1
fi

MAX_WORDS=8

trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

total_rows=0
issues_found=0
issue_lines=()

line_no=0
while IFS= read -r line || [[ -n "$line" ]]; do
    line_no=$((line_no + 1))

    # Chỉ xét các dòng thuộc bảng markdown (bắt đầu và kết thúc bằng |)
    [[ "$line" == \|*\| ]] || continue

    # Bỏ qua dòng header và dòng phân cách của bảng
    [[ "$line" == *"Cụm từ tiếng Anh"* ]] && continue
    [[ "$line" =~ ^\|[-:\ ]+\|[-:\ ]+\|[-:\ ]+\|$ ]] && continue

    IFS='|' read -r _ eng ipa vi _ <<< "$line"
    eng="$(trim "$eng")"

    [[ -z "$eng" ]] && continue

    # Bỏ qua dòng placeholder lời bài hát (không phải cụm từ cần kiểm tra độ dài)
    [[ "$eng" == *"lời bài hát"* ]] && continue

    total_rows=$((total_rows + 1))

    word_count=$(wc -w <<< "$eng" | tr -d ' ')

    if (( word_count > MAX_WORDS )); then
        issues_found=$((issues_found + 1))
        issue_lines+=("Dòng $line_no: \"$eng\" ($word_count từ) — quá dài")
    fi
done < "$FILE"

echo "File: $FILE"
echo "Tổng số cụm từ trong bảng: $total_rows"
echo

if [[ $issues_found -eq 0 ]]; then
    echo "Không có dòng nào quá dài (tối đa $MAX_WORDS từ)."
else
    echo "Các dòng có vấn đề ($issues_found):"
    for entry in "${issue_lines[@]}"; do
        echo "  $entry"
    done
fi
