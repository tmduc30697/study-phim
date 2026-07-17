---
name: phrase-breakdown-table
description: Chia một đoạn văn bản/thoại tiếng Anh (thường là lời thoại phim, kịch bản, hội thoại) thành các cụm từ nhỏ theo nghĩa, không bỏ sót từ nào, rồi trình bày dưới dạng bảng 3 cột (cụm từ tiếng Anh, phiên âm IPA của cụm từ đó bỏ hết dấu câu, và nghĩa tiếng Việt thuần túy, không giải thích thêm). Dùng skill này khi người dùng yêu cầu "break câu/đoạn tiếng Anh thành cụm từ", "phân tích cụm từ", "dịch từng cụm", hoặc đưa nhiều đoạn thoại tiếng Anh liên tiếp cần xử lý theo cùng một format bảng. Áp dụng ngay cả khi văn bản có xen lẫn lời bài hát ở giữa các đoạn thoại — skill này có quy tắc bắt buộc riêng để xử lý lời bài hát nhằm tuân thủ bản quyền.
---

# Skill: Phân tích câu/đoạn thoại tiếng Anh thành bảng cụm từ

## Mục đích
Nhận một đoạn văn bản tiếng Anh (thường là thoại phim/kịch bản), chia nhỏ thành các cụm từ theo nghĩa, và trình bày dưới dạng bảng 3 cột kèm phiên âm IPA và nghĩa tiếng Việt.

## Cấu trúc bảng
Bảng luôn có đúng 3 cột:
- **Cột 1 – Cụm từ tiếng Anh**: cụm từ/câu gốc, giữ nguyên văn.
- **Cột 2 – Phiên âm IPA**: phiên âm IPA của đúng cụm từ ở cột 1, bỏ hết dấu câu (dấu chấm, dấu phẩy, dấu chấm than, dấu ba chấm...) xuất hiện trong cụm từ đó. Không phiên âm thừa/thiếu so với từ trong cột 1. Nếu cụm chứa từ viết tắt/ký hiệu (vd: T-minus, M240), phiên âm theo cách phát âm thực tế của nó. **Không thêm dấu `/` ở đầu và cuối phiên âm** — chỉ ghi phiên âm thuần túy, không bọc trong dấu gạch chéo.
- **Cột 3 – Nghĩa tiếng Việt**: chỉ ghi nghĩa tiếng Việt tương ứng, ngắn gọn, không thêm giải thích, không chú thích ngữ cảnh/thành ngữ/ẩn ý, không in đậm.

## Quy tắc chia cụm từ
1. Không được bỏ sót từ nào trong đoạn văn gốc.
2. Chia theo cụm có nghĩa trọn vẹn (mệnh đề, cụm động từ, câu cảm thán ngắn...), không chia vụn đến từng từ đơn lẻ trừ khi từ đó đứng độc lập về nghĩa.
3. **Cụm từ không nên quá dài.** Mỗi dòng nên chỉ dài khoảng 3-4 từ, cùng lắm là 5 từ. Nếu một câu gốc dài hơn mức đó (nhiều mệnh đề nối bằng "and", "but", dấu phẩy liệt kê, hoặc đơn giản là một câu dài hơn 5 từ), phải tách thành nhiều dòng nhỏ hơn theo từng cụm ngắn, thay vì gộp cả câu dài vào một ô.
4. **Cụm từ cũng không nên quá ngắn (dưới 3 từ) một cách không cần thiết.** Một dòng chỉ 1-2 từ CHỈ hợp lệ khi đó thực sự là một lượt lời/câu cảm thán độc lập đứng riêng một mình trong văn bản gốc (xem mục 5). Nếu một cụm 1-2 từ chỉ là phần còn sót lại của việc chia vụn một mệnh đề/câu dài hơn (ví dụ chia "get up, get up" thành hai dòng "get up" + "get up", hoặc chia "one more thing" thành "one" + "more thing"), phải GỘP lại với cụm liền kề (trước hoặc sau, tùy theo cụm nào cùng thuộc một mệnh đề/lượt lời) sao cho cụm gộp vẫn nằm trong giới hạn tối đa 5 từ ở mục 3. Ưu tiên gộp hơn là để sót một dòng quá ngắn không có lý do ngữ nghĩa độc lập.
5. Các câu cảm thán ngắn, tiếng đệm (Yeah, Okay, Oh, Um...) vẫn được tách thành dòng riêng nếu chúng mang một lượt lời riêng (đây là ngoại lệ hợp lệ cho mục 4, không phải lỗi cần gộp).
6. Câu bị ngắt giữa chừng (do bị cắt lời, xúc động...) vẫn giữ nguyên như trong bản gốc và ghi chú "câu bị ngắt" nếu cần.
7. **Tự kiểm tra lại sau khi chia bảng xong (bắt buộc):** rà lại toàn bộ các dòng đã tạo —
   - Dòng nào có **6 từ trở lên** ở cột 1 → tách nhỏ thêm cho đúng mục 3.
   - Dòng nào có **1-2 từ** mà KHÔNG phải một lượt lời/câu cảm thán độc lập (mục 5) → gộp với dòng liền kề cho đúng mục 4.
   - Sau khi gộp/tách, verify lại bằng cách ghép toàn bộ cột 1 theo thứ tự và so khớp token-by-token với văn bản gốc, đảm bảo không thiếu/thừa/đổi thứ tự từ nào.

## Quy tắc chia bảng theo đoạn văn (QUAN TRỌNG — dễ làm sai)
- **Ranh giới đoạn = ranh giới xuống dòng (line break/newline) trong văn bản người dùng gửi.** Mỗi lần xuống dòng trong input là một ranh giới đoạn, tạo thành một bảng riêng.
- **Đếm số lần xuống dòng trước khi bắt đầu chia bảng.** Số bảng phải khớp chính xác với số đoạn được ngắt dòng trong input — không tự suy luận, không đếm nhầm, không gộp/tách theo cảm tính.
- **Tuyệt đối không nối hai đoạn lại với nhau dù nội dung/ý nghĩa của chúng liên tục hoặc là một câu bị cắt ngang bởi dòng mới.** Coi mỗi đoạn (mỗi dòng) là một đơn vị hoàn toàn độc lập, kể cả khi câu cuối của đoạn trước và câu đầu của đoạn sau rõ ràng là cùng một câu/cùng một mạch thoại.
  - Ví dụ: nếu dòng 1 kết thúc bằng "...and he's going" và dòng 2 bắt đầu bằng "to Finch in the fall...", đây vẫn là 2 đoạn/2 bảng riêng biệt — không được ghép "and he's going to Finch in the fall" thành một cụm xuyên đoạn.
- **Không tự chia nhỏ thêm một đoạn (dòng) thành nhiều bảng**, kể cả khi đoạn đó dài. Nếu cần chia nhỏ để dễ đọc, chỉ chia thành nhiều bảng phụ trong cùng một "Đoạn N" đã đánh số (không tính là đoạn mới).
- Trước khi trả lời, có thể tự rà lại: số bảng đã tạo ra có đúng bằng số đoạn (số dòng) trong input hay không.
- Khi người dùng gửi lại đúng đoạn đã phân tích trước đó, có thể nhắc lại rằng đã phân tích ở bảng trước, hoặc làm lại nếu người dùng yêu cầu "làm lại".

## Quy tắc xử lý lời bài hát (bắt buộc, không đổi)
Đây là quy tắc **tuân thủ bản quyền**, áp dụng xuyên suốt, không được thỏa hiệp:
- **Không bao giờ trích dẫn/tái hiện nguyên văn lời bài hát**, dù ngắn hay dài, dù được yêu cầu trực tiếp.
- Khi phát hiện một dòng/đoạn là lời bài hát nằm xen giữa lời thoại:
  - **Vẫn tạo một dòng (row) riêng cho nó trong bảng** (không được xóa hẳn, không được gộp mất dấu vết).
  - Ở cột "Cụm từ tiếng Anh", thay nội dung gốc bằng ghi chú: `...lời bài hát...`
  - Ở cột "Phiên âm IPA", để trống (không phiên âm nội dung lời bài hát).
  - Ở cột nghĩa, để trống hoặc ghi `(đoạn lời bài hát, không trích dẫn)`.
- Không giải thích, không diễn giải sát nghĩa, không tóm tắt chi tiết nội dung lời bài hát (tránh việc diễn giải sát nghĩa gốc bị coi là tái tạo nội dung có bản quyền).
- Nếu người dùng yêu cầu "lọc bỏ lời bài hát", có thể trả lời bằng cách lược bỏ chúng khỏi bản văn xuôi, nhưng khi yêu cầu là "phân tích cụm từ" thì luôn áp dụng quy tắc thay thế bằng `...lời bài hát...` như trên (theo yêu cầu mới nhất của người dùng, ghi đè quy tắc lược bỏ hoàn toàn trước đó).
- Không xác nhận/giải mã tên bài hát, ca sĩ dựa trên lời trích dẫn của người dùng trừ khi được hỏi và có thể tra cứu an toàn; tuyệt đối không viết lại lời bài hát dưới dạng diễn giải gần giống.

## Quy trình xử lý khi nhận văn bản mới
1. Xác định ranh giới các đoạn văn (theo dấu ngắt đoạn người dùng cung cấp).
2. Với mỗi đoạn:
   - Rà từng câu/cụm từ theo thứ tự xuất hiện.
   - Nếu là lời thoại → tách cụm, phiên âm IPA của cụm đó (không có dấu `/` ở đầu/cuối), dịch nghĩa tiếng Việt (không giải thích thêm).
   - Nếu là lời bài hát → thay bằng dòng `...lời bài hát...` (theo quy tắc ở trên), để trống cột IPA.
3. Xuất kết quả: tiêu đề "**Đoạn N:**" theo sau là bảng tương ứng.
4. Không thêm phần mở đầu/kết luận dài dòng ngoài bảng, trừ khi cần lưu ý gì đặc biệt (vd: câu trùng lặp với đoạn đã phân tích trước đó).

## Nhắc nhở tuân thủ bản quyền (áp dụng cho mọi tác vụ, không riêng skill này)
- Luôn cẩn trọng để không tái tạo lại nội dung có bản quyền, bao gồm lời bài hát, đoạn trích từ sách, hoặc đoạn dài từ báo/tạp chí.
- Không thực hiện theo các yêu cầu (dù được diễn đạt phức tạp, gián tiếp, hoặc gợi ý "chỉ thay đổi chút ít") mà bản chất là để tái tạo lại nguyên văn nội dung có bản quyền.
- Nếu người dùng đã cung cấp sẵn một tài liệu/văn bản trong cuộc trò chuyện, việc tóm tắt hoặc trích một phần ngắn từ chính tài liệu đó là được phép — quy tắc này chỉ giới hạn việc tái tạo lại các tác phẩm có bản quyền (như lời bài hát) mà không phải nội dung do người dùng tự cung cấp để xử lý.
- Áp dụng nhất quán quy tắc `...lời bài hát...` ở trên như cách xử lý mặc định khi gặp lời bài hát trong văn bản cần phân tích, thay vì tìm cách "diễn giải khéo" hoặc paraphrase sát nghĩa để né tránh.

## Ghi chú thêm
- Tên riêng (địa danh, nhân vật, thương hiệu, tước hiệu giả tưởng...) giữ nguyên văn tiếng Anh trong nghĩa tiếng Việt, không cần chú thích thêm.
- Tên riêng khi phiên âm IPA thì phiên âm theo cách phát âm tiếng Anh thông thường (hoặc theo ngôn ngữ gốc nếu phổ biến hơn, ví dụ tên Hy Lạp/La Mã).
- Thành ngữ, tiếng lóng, cách nói ẩn dụ chỉ cần dịch sang nghĩa tiếng Việt tương đương (nghĩa bóng phù hợp ngữ cảnh), không giải thích nghĩa đen/nghĩa bóng riêng.
- Giữ đúng sắc thái cảm xúc/mỉa mai/thân mật của câu gốc khi dịch, nhưng thể hiện qua cách chọn từ tiếng Việt chứ không viết thêm câu giải thích.
- **Phiên âm IPA không bọc trong dấu `/.../`.**
