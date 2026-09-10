/*
 CREATE DATABASE IF NOT EXISTS louja;
USE louja;
CREATE TABLE IF NOT EXISTS produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    imagem TEXT NOT NULL
);

*/
INSERT INTO produtos (nome, categoria, preco, imagem) VALUES
('Sobretudo Lã Premium', 'Edição Limitada 01', 1199.00, 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=1200&q=80'),
('Blazer Alfaiataria Oversized', 'Edição Limitada 02', 799.00, 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?auto=format&fit=crop&w=1200&q=80'),
('Vestido Plissado Minimal', 'Edição Limitada 03', 659.00, 'https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?auto=format&fit=crop&w=1200&q=80'),
('Bota Couro Cano Alto', 'Edição Limitada 04', 899.00, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=1200&q=80');