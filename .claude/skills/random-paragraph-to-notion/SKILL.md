---
name: random-paragraph-to-notion
description: Chọn ngẫu nhiên N đoạn (N truyền vào qua args, mặc định 1) — mỗi đoạn là 1 folder ngẫu nhiên + 1 file paragraph-*.md ngẫu nhiên trong folder đó (thuộc dự án học tiếng Anh qua thoại phim tại study-phim), rồi copy đoạn văn gốc + bảng cụm từ (rút gọn còn 2 cột: cột 1 gộp câu tiếng Anh và phiên âm IPA, câu Anh ở trên dòng trên và IPA ở dòng dưới cùng ô; cột 2 là nghĩa tiếng Việt) lên một trang Notion cố định để ôn tập. Dùng skill này khi người dùng yêu cầu "chọn ngẫu nhiên N file rồi đẩy lên Notion", "random N đoạn đưa lên Notion ôn tập", "gửi bảng ngẫu nhiên lên Notion", hoặc các biến thể tương tự về việc lấy nội dung ngẫu nhiên từ thư mục study-phim rồi nối vào trang Notion để ôn luyện.
---

# Skill: Random paragraph → Notion (bảng 2 cột)

## Mục đích
Lấy ngẫu nhiên một hoặc nhiều đoạn thoại phim đã được xử lý (hoặc cần xử lý) trong dự án `study-phim`, rồi nối (append) nội dung đó — đoạn văn gốc + bảng học từ dạng rút gọn 2 cột — vào cuối một trang Notion cố định, phục vụ mục đích ôn tập ngẫu nhiên.

## Input — số lượng đoạn (N)
- Skill nhận 1 tham số qua `args`: **số đoạn cần bốc ngẫu nhiên**, ví dụ gọi `/random-paragraph-to-notion 5` nghĩa là N = 5.
- Nếu người dùng không truyền số, hoặc gọi skill không kèm args → mặc định **N = 1** (giữ hành vi gốc).
- Nếu args không parse được thành số nguyên dương hợp lệ, hỏi lại người dùng muốn bốc bao nhiêu đoạn thay vì tự đoán.
- Mỗi đoạn trong N đoạn là **một lượt chọn ngẫu nhiên độc lập** (thực hiện lại Bước 1 + Bước 2 riêng cho từng đoạn) — không cố tránh trùng lặp, có thể ngẫu nhiên trùng cùng 1 file giữa các lượt, việc đó chấp nhận được vì bản chất là random.

## Trang Notion đích (cố định)
- Link: `https://app.notion.com/p/2026-07-13-39c5a8f43dc9803e962fd3e8d4c53a17?source=copy_link`
- Page ID (dùng cho các tool Notion): `39c5a8f4-3dc9-803e-962f-d3e8d4c53a17`
- Luôn **append vào cuối trang** (không ghi đè nội dung đã có sẵn trên trang), dùng `notion-update-page` với `command: "insert_content"`, `position: {"type": "end"}`.
- Nếu Notion trả lỗi `object_not_found`, khả năng cao trang chưa được share với connector, hoặc connector đang trỏ sai workspace — báo cho người dùng kiểm tra lại quyền truy cập/workspace trước khi thử lại, không tự đoán ID khác.

## Quy trình thực hiện

Lặp lại Bước 1 → Bước 4 đúng **N lần** (N lấy từ Input ở trên), mỗi lần tạo ra 1 khối nội dung (heading + đoạn văn gốc + bảng 2 cột) cho 1 đoạn. Sau khi có đủ N khối, mới thực hiện Bước 5 một lần duy nhất để đẩy toàn bộ N khối lên Notion theo đúng thứ tự đã bốc.

### Bước 1 — Chọn ngẫu nhiên 1 folder
- Liệt kê các **thư mục con** (không phải file lẻ) ở gốc dự án `study-phim`, loại trừ `.claude` và các thư mục ẩn khác.
- Chọn ngẫu nhiên 1 thư mục trong số đó. Ví dụ lệnh:
  ```
  python3 -c "
  import os, random
  dirs = [d for d in os.listdir('.') if os.path.isdir(d) and not d.startswith('.')]
  print(random.choice(dirs))
  "
  ```
- Không dùng `shuf` (không có sẵn trên macOS mặc định).

### Bước 2 — Chọn ngẫu nhiên 1 file paragraph trong folder đó
- Liệt kê các file `.md` (thường có tên dạng `paragraph-N.md`) trong folder vừa chọn.
- Chọn ngẫu nhiên 1 file trong số đó (tương tự cách dùng `random.choice` ở Bước 1).
- Đọc nội dung file bằng Read tool.

### Bước 3 — Đảm bảo file có sẵn bảng cụm từ
- File paragraph chuẩn có cấu trúc: dòng 1 là đoạn thoại tiếng Anh gốc, theo sau là bảng markdown 3 cột (`Cụm từ tiếng Anh | Phiên âm IPA | Nghĩa tiếng Việt`) do skill `phrase-breakdown-table` tạo ra trước đó.
- **Nếu file đã có bảng 3 cột này** → dùng trực tiếp dữ liệu đó ở Bước 5.
- **Nếu file CHƯA có bảng** (chỉ có đúng 1 dòng nội dung gốc) → phải tạo bảng trước:
  - Gọi Skill tool với `skill="phrase-breakdown-table"` để lấy đầy đủ quy tắc chia cụm/IPA/nghĩa.
  - Áp dụng quy tắc đó để chia đoạn văn thành bảng 3 cột.
  - Append bảng 3 cột này vào file gốc bằng Edit tool (giữ đúng quy ước định dạng đã dùng trong dự án: dòng nội dung gốc, 1 dòng trống, header, dòng phân cách, các dòng dữ liệu) — để lần sau file này đã có sẵn bảng, không phải làm lại.

### Bước 4 — Chuẩn bị nội dung đưa lên Notion
Chuyển bảng 3 cột thành bảng **2 cột** theo quy tắc:
- Cột 1 "Cụm từ tiếng Anh": gộp câu tiếng Anh và phiên âm IPA vào cùng 1 ô, câu tiếng Anh ở dòng trên, phiên âm IPA ở dòng dưới, ngăn cách bằng `<br>` (theo cú pháp Notion-flavored Markdown, không phải thẻ HTML thường).
- Cột 2 "Nghĩa tiếng Việt": giữ nguyên như bảng gốc.
- Trước khi dùng tool `notion-update-page`/`notion-create-pages`, đọc resource `notion://docs/enhanced-markdown-spec` (qua ReadMcpResourceTool, server `claude_ai_Notion`) nếu chưa nắm rõ cú pháp bảng Notion, để đảm bảo dùng đúng cấu trúc XML-like:
  ```
  <table fit-page-width="true" header-row="true">
  <tr>
  <td>Cụm từ tiếng Anh</td>
  <td>Nghĩa tiếng Việt</td>
  </tr>
  <tr>
  <td>{câu tiếng Anh}<br>{IPA}</td>
  <td>{nghĩa tiếng Việt}</td>
  </tr>
  ...
  </table>
  ```
- Escape các ký tự đặc biệt trong nội dung ô bảng theo quy tắc Notion Markdown: `\ * ~ \` $ [ ] < > { } | ^` (thêm `\` phía trước mỗi ký tự này nếu xuất hiện trong nội dung, trừ chính cú pháp `<br>` và các thẻ `<table>/<tr>/<td>` dùng để dựng bảng).
- Không dùng bảng markdown dạng `| a | b |` thông thường cho Notion — Notion cần cú pháp `<table>` như trên (bảng pipe thường không tạo ra table block thực sự khi insert qua API).

### Bước 5 — Đẩy lên Notion (1 lần duy nhất cho cả N đoạn)
- Nếu tool Notion chưa được nạp trong phiên làm việc, dùng ToolSearch với `select:mcp__claude_ai_Notion__notion-update-page,mcp__claude_ai_Notion__notion-fetch` để nạp.
- Ghép N khối nội dung đã chuẩn bị ở Bước 1-4 lại theo đúng thứ tự đã bốc, mỗi khối gồm:
  1. Một heading ngắn để biết nguồn gốc đoạn này, ví dụ: `## {tên folder} — {tên file}` (dùng đúng tên thư mục/file đã chọn ở Bước 1-2 để dễ tra cứu sau này).
  2. Đoạn văn tiếng Anh gốc (nguyên văn dòng 1 của file), dạng văn bản thường.
  3. Bảng 2 cột theo cú pháp `<table>` ở Bước 4.
- Gọi `notion-update-page` **một lần** với toàn bộ nội dung đã ghép:
  - `page_id`: `39c5a8f43dc9803e962fd3e8d4c53a17`
  - `command`: `insert_content`
  - `position`: `{"type": "end"}`
  - `content`: chuỗi nội dung đã ghép N khối, mỗi khối cách nhau 1 dòng trống.
- Nếu N lớn (nội dung quá dài, ví dụ N > ~15-20 đoạn tùy độ dài mỗi đoạn) và lo ngại vượt giới hạn 1 lần gọi, có thể chia thành nhiều lần gọi `insert_content` liên tiếp (mỗi lần vài đoạn) thay vì 1 lần duy nhất — miễn là vẫn append đúng thứ tự vào cuối trang.
- Sau khi insert xong, có thể fetch lại trang (`notion-fetch` với id là page ID) để xác nhận nội dung đã được thêm đúng, nếu cần chắc chắn trước khi báo hoàn tất.

## Lưu ý
- Mỗi đoạn trong N đoạn dùng 2 lượt chọn ngẫu nhiên độc lập (folder, rồi file trong folder đó) — không cố định theo alphabet hay theo thứ tự file, mỗi lần chạy skill có thể ra kết quả khác nhau.
- Nếu folder được chọn ngẫu nhiên không có file `.md` nào bên trong, chọn lại 1 folder khác (không báo lỗi cho người dùng vì chuyện này không quan trọng, cứ âm thầm thử lại).
- Không tự ý sửa/xóa nội dung đã có sẵn trên trang Notion đích — chỉ được append thêm.
- Nếu người dùng không nói rõ, mặc định luôn thực hiện đủ cả 2 việc cho từng đoạn: (a) copy đoạn văn gốc, và (b) copy bảng 2 cột — như mô tả trong yêu cầu gốc, không bỏ bớt phần nào.
- Sau khi hoàn tất, báo lại cho người dùng danh sách N đoạn đã bốc (tên folder/file) để họ biết đã ôn tập nội dung nào.
