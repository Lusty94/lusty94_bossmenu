CREATE TABLE IF NOT EXISTS `employee_messages` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `job` VARCHAR(100) NOT NULL,
    `sender_name` VARCHAR(100) NOT NULL,
    `message` TEXT NOT NULL,
    `boss_reply` TEXT DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `replied_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
