/* =============================================================================
   DANH SÁCH BÀI TOÁN: Histogram of Tweets (Twitter SQL Interview Question)
   MỨC ĐỘ: Dễ (Easy)
   LINK BÀI TOÁN: https://datalemur.com/questions/sql-histogram-tweets
   =============================================================================
   
   1. ĐỀ BÀI (TÓM TẮT):
   Giả sử bạn được yêu cầu phân tích dữ liệu Twitter. Hãy viết một truy vấn để 
   tính số lượng người dùng (users) đã đăng một số lượng bài viết (tweets) cụ thể 
   trong năm 2022. 
   Đầu ra mong muốn gồm 2 cột: số lượng tweet (bucket) và số lượng user thuộc bucket đó.

   2. PHÂN TÍCH TƯ DUY (LOGIC GIẢI QUYẾT):
   - Bước 1: Lọc dữ liệu các tweet được đăng trong năm 2022 bằng hàm EXTRACT hoặc toán tử BETWEEN.
   - Bước 2: Gom nhóm theo từng `user_id` và dùng `COUNT(tweet_id)` để tính xem trong năm đó mỗi người đăng bao nhiêu bài.
   - Bước 3: Đề bài yêu cầu đếm ngược lại có bao nhiêu user cho mỗi số lượng tweet(đây là phần lắc léo).
    Vì vậy, ta phải coi kết quả ở Bước 2 như một bảng tạm (Subquery hoặc CTE), sau đó tiếp tục GROUP BY theo số lượng tweet vừa tính được và dùng `COUNT(user_id)` để ra kết quả cuối cùng.
============================================================================= */

-- BƯỚC 1 & 2: Dùng CTE để tạo bảng tạm tính số lượng tweet của mỗi user trong năm 2022
WITH total_tweets_per_user AS (
  SELECT 
    user_id,
    COUNT(tweet_id) AS tweet_count
  FROM tweets
  WHERE tweet_date BETWEEN '2022-01-01' AND '2022-12-31' -- Chỉ lọc dữ liệu năm 2022(Ta có thể dùng EXTRACT(YEAR FROM tweet_date)=2022)
  GROUP BY user_id
)

-- BƯỚC 3: Truy vấn chính để nhóm các user có cùng số lượng tweet vào các "bucket"
SELECT 
  tweet_count AS tweet_bucket,            -- Số lượng bài viết (Ví dụ: 1 tweet, 2 tweets...)
  COUNT(user_id) AS users_num             -- Tổng số lượng người dùng đạt mức tweet đó
FROM total_tweets_per_user
GROUP BY tweet_count                      -- Nhóm lại theo số lượng tweet
ORDER BY tweet_bucket ASC;                -- Sắp xếp tăng dần theo yêu cầu đề bài


/*
  - Với bài toán này ta cũng có thể dùng Subquery như sau:
 SELECT 
    SumTweetOfUser AS tweet_bucket,
    COUNT(user_id) AS users_num
FROM (
    SELECT  
        user_id,
        COUNT(tweet_id) AS SumTweetOfUser
    FROM tweets
    WHERE EXTRACT(YEAR FROM tweet_date) = 2022
    GROUP BY user_id
) AS total_tweets -- Bắt buộc phải có tên đại diện (alias) cho subquery
GROUP BY SumTweetOfUser
ORDER BY tweet_bucket ASC;
*/

/* =============================================================================
   3. BÀI HỌC RÚT RA (KỸ THUẬT SQL):
   - Bài toán này giúp mình rèn luyện kỹ thuật "Gom nhóm 2 lần" (Double Aggregation).
   - Sử dụng CTE (Common Table Expression) thay vì Subquery lồng nhau giúp code 
     trông sạch sẽ, dễ đọc, dễ bảo trì hơn.

  4. LỖI SAI CỦA MÌNH TRONG QUÁ TRÌNH GIẢI VÀ BÀI HỌC THÊM
  - Ban đầu mình viết bằng Subquery(mình luốn cuốn chỉ việc được query lồng bên trong thôi nghĩa là chỉ làm được bước 1)
  - Mình viết xong xem đáp án thì check ra một số lỗi như: quên đặt tên alias, có dấu ; trong subquery
  - Mình chưa hiểu rõ nên đã dùng distinct (bước 2) và group by nên gây ra lỗi - học được cách sử dụng distinct, group by
============================================================================= */
