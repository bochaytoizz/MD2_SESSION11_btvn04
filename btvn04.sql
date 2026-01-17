USE Session11_DB;
INSERT INTO accounts(customerName,balance)
VALUES('Phạm Đức Hiếu', 0);

DELIMITER //
CREATE PROCEDURE  transfer_money (  IN p_sender_id INT,
                                    IN p_receiver_id INT,
									IN p_amount DECIMAL(15,2) )
BEGIN
                 -- Khai báo biến để kiểm tra số dư 
                 DECLARE v_sender_balance DECIMAL(15,2);
                 
                 -- KHỐI XỬ LÝ LỖI TỰ ĐỘNG
                 -- Nếu gặp bất kỳ lỗi SQL mào (SQLEXCEPTION) -> Tự động Rollback
				 DECLARE EXIT HANDLER FOR SQLEXCEPTION
                 BEGIN
                 ROLLBACK;
                 SELECT 'Giao dịch thất bại: Lõi hệ thống SQL!' AS message;
                 END;
                 
                 -- Bắt đầu giao dịch
                 START TRANSACTION;
                 
                 -- 1. Kiểm tra số dư người gửi ( sd "FOR UPDATE" để khóa dòng này lại tránh xong đột)
                  SELECT balance INTO v_sender_balance
                  FROM accounts
                  WHERE accountID = p_sender_id
                  FOR UPDATE;
                  
                  -- 2. Kiểm  tra điều kiện logic
                  IF v_sender_balance >= p_amount THEN
                  
                      -- Trừ tiền người gửi
                      UPDATE accounts
                      SET balance = balance - p_amount
                      WHERE accountID = p_sender_id;
                  
                      -- Cộng tiền người nhận
					  UPDATE accounts
                      SET balance = balance + p_amount
                      WHERE accountID = p_receiver_id;
                  
                      -- Xác nhận thành công 
                      COMMIT;
                      SELECT 'Chuyển tiền thành công!' AS message;
       
                  ELSE 
                      -- Tiền không đủ -> Hủy
                      ROLLBACK;
                      SELECT 'Giao dịch thất bại, số dư không đủ!' AS massage;
				 END IF;
                 
 END //
  
 DELIMITER ;
 
 -- Kiểm thử
-- Kiểm tra trước khi chuyển
SELECT * FROM accounts WHERE accountID IN (10, 11);

-- Thực hiện chuyển 300.000
CALL transfer_money(10, 11, 300000);
 
 -- Kiểm tra kết quả sau khi chuyển của account_id 10 and 11
SELECT * FROM accounts WHERE accountID IN (10, 11);
				
                  
