ALTER TABLE `user_telegram` ADD `opted_in` BOOLEAN NOT NULL DEFAULT FALSE AFTER `telegram`; 

ALTER TABLE `user_telegram` ADD `id` INT NOT NULL AUTO_INCREMENT FIRST, ADD PRIMARY KEY (`id`); 

ALTER TABLE `user_telegram` ADD CONSTRAINT `fk_user_telegram_charid` FOREIGN KEY (`charid`) REFERENCES `characters`(`charidentifier`) ON DELETE NO ACTION ON UPDATE NO ACTION; 

ALTER TABLE `user_telegram` ADD CONSTRAINT `fk_user_telegram_user` FOREIGN KEY (`identifier`) REFERENCES `users`(`identifier`) ON DELETE NO ACTION ON UPDATE NO ACTION; 

ALTER TABLE `redm`.`user_telegram` ADD UNIQUE (`telegram`); 