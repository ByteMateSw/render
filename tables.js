    const tableStatements = [
      // País, provincia, ciudad - BRANCH_ID NULLABLE
      `CREATE TABLE IF NOT EXISTS country (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    name VARCHAR(100) NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL,
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0
  )`,

      `CREATE TABLE IF NOT EXISTS province (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    country_id VARCHAR(36) NOT NULL, 
    name VARCHAR(100) NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL,
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (country_id) REFERENCES country(id)
  )`,

      `CREATE TABLE IF NOT EXISTS city (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    province_id VARCHAR(36) NOT NULL, 
    name VARCHAR(100) NOT NULL, 
    postal_code VARCHAR(20), 
    branch_id VARCHAR(36) NULL DEFAULT NULL,
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (province_id) REFERENCES province(id)
  )`,

      // Sucursales - BRANCH_ID NULLABLE PARA EVITAR REFERENCIAS CIRCULARES
      // 🔧 CORRECCIÓN: Agregar DEFAULT (UUID()) para evitar "Field 'id' doesn't have a default value"
      `CREATE TABLE IF NOT EXISTS branch (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    city_id VARCHAR(36) NULL, 
    name VARCHAR(100) NOT NULL, 
    address VARCHAR(200) NOT NULL, 
    phone VARCHAR(20), 
    branch_id VARCHAR(36) NULL DEFAULT NULL,
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (city_id) REFERENCES city(id)
  )`,

      // Roles y estados - BRANCH_ID NULLABLE
      `CREATE TABLE IF NOT EXISTS role (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    name VARCHAR(50) NOT NULL, 
    discount FLOAT DEFAULT 0, 
    branch_id VARCHAR(36) NULL DEFAULT NULL,
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0
  )`,

      `CREATE TABLE IF NOT EXISTS status (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    name VARCHAR(50) NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL,
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0
  )`,

      // Unidades y categorías - BRANCH_ID NULLABLE
      `CREATE TABLE IF NOT EXISTS unit_measure (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    name VARCHAR(50) NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL,
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0
  )`,

      `CREATE TABLE IF NOT EXISTS category (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    name VARCHAR(100) NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL,
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0
  )`,

      // Usuarios - ESTRUCTURA ACTUALIZADA CON RESPONSABILIDAD FISCAL DIRECTA
      `CREATE TABLE IF NOT EXISTS user (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    city VARCHAR(36) NULL, 
    name VARCHAR(100) NOT NULL, 
    dni VARCHAR(20) UNIQUE NOT NULL, 
    cuil VARCHAR(20) UNIQUE NOT NULL, 
    phone VARCHAR(20), 
    email VARCHAR(100) NOT NULL, 
    address VARCHAR(200) NOT NULL, 
    role VARCHAR(36), 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    debt FLOAT DEFAULT 0, 
    credit FLOAT DEFAULT 0, 
    credit_limit FLOAT DEFAULT 0,
    responsabilidad_fiscal VARCHAR(100) NULL COMMENT 'Tipo de responsabilidad: Responsable Inscripto, Monotributista, etc.',
    iibb_alicuota FLOAT NULL COMMENT 'Alícuota de IIBB como número decimal',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (city) REFERENCES city(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      // Empleados
      `CREATE TABLE IF NOT EXISTS employee (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    username VARCHAR(50) NOT NULL, 
    password VARCHAR(100) NOT NULL, 
    role_id VARCHAR(36) NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    status_id VARCHAR(36) NOT NULL, 
    user_id VARCHAR(36) NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (role_id) REFERENCES role(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id), 
    FOREIGN KEY (status_id) REFERENCES status(id), 
    FOREIGN KEY (user_id) REFERENCES user(id)
  )`,

      // Clientes - ESTRUCTURA SIMPLIFICADA SIN REFERENCIAS A TAX
      `CREATE TABLE IF NOT EXISTS client (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    user_id VARCHAR(36) NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (user_id) REFERENCES user(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      `CREATE TABLE IF NOT EXISTS provider (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    user_id VARCHAR(36) NOT NULL, 
    cuit VARCHAR(20) NOT NULL, 
    social_reason VARCHAR(100) NOT NULL, 
    iibb VARCHAR(20), 
    respo_iva VARCHAR(50), 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (user_id) REFERENCES user(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      // Productos y stock
      `CREATE TABLE IF NOT EXISTS product (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    barcode VARCHAR(32), 
    name VARCHAR(100) NOT NULL, 
    category VARCHAR(36) NOT NULL, 
    min_stock FLOAT NOT NULL, 
    iva FLOAT NOT NULL, 
    discount FLOAT DEFAULT 0, 
    unit_measure_id VARCHAR(36) NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (category) REFERENCES category(id), 
    FOREIGN KEY (unit_measure_id) REFERENCES unit_measure(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      `CREATE TABLE IF NOT EXISTS product_branch (
    product_id VARCHAR(36) NOT NULL, 
    branch_id VARCHAR(36) NOT NULL, 
    amount FLOAT NOT NULL DEFAULT 0, 
    minor_price FLOAT NOT NULL, 
    mayor_price FLOAT NOT NULL, 
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    PRIMARY KEY (product_id, branch_id), 
    FOREIGN KEY (product_id) REFERENCES product(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      // Comprobantes - BRANCH_ID NULLABLE
      `CREATE TABLE IF NOT EXISTS voucher_type (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    name VARCHAR(50) NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL,
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0
  )`,

      // Compras y ventas
      `CREATE TABLE IF NOT EXISTS purchase (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    voucher_type_id VARCHAR(36) NOT NULL, 
    client VARCHAR(36) NULL DEFAULT NULL, 
    provider VARCHAR(36) NOT NULL, 
    employee VARCHAR(36) NOT NULL, 
    total FLOAT NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (voucher_type_id) REFERENCES voucher_type(id), 
    FOREIGN KEY (client) REFERENCES client(id), 
    FOREIGN KEY (provider) REFERENCES provider(id), 
    FOREIGN KEY (employee) REFERENCES employee(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      `CREATE TABLE IF NOT EXISTS sale (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    employee VARCHAR(36) NOT NULL, 
    client VARCHAR(36) NOT NULL, 
    voucher_type_id VARCHAR(36) NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (branch_id) REFERENCES branch(id), 
    FOREIGN KEY (employee) REFERENCES employee(id), 
    FOREIGN KEY (client) REFERENCES client(id), 
    FOREIGN KEY (voucher_type_id) REFERENCES voucher_type(id)
  )`,

      // Productos en compras y ventas
      `CREATE TABLE IF NOT EXISTS sale_product (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    product_id VARCHAR(36) NOT NULL, 
    sale_id VARCHAR(36) NOT NULL, 
    unit_price FLOAT NOT NULL, 
    amount FLOAT NOT NULL, 
    sub_total FLOAT NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (product_id) REFERENCES product(id), 
    FOREIGN KEY (sale_id) REFERENCES sale(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      `CREATE TABLE IF NOT EXISTS purchase_product (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    product_id VARCHAR(36) NOT NULL, 
    purchase_id VARCHAR(36) NOT NULL, 
    unit_price FLOAT NOT NULL, 
    amount FLOAT NOT NULL, 
    sub_total FLOAT NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (product_id) REFERENCES product(id), 
    FOREIGN KEY (purchase_id) REFERENCES purchase(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      // Métodos de pago - BRANCH_ID NULLABLE
      `CREATE TABLE IF NOT EXISTS payment_method (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    name VARCHAR(50) NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL,
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0
  )`,

      // Pagos
      `CREATE TABLE IF NOT EXISTS sale_payment (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    sale_id VARCHAR(36) NOT NULL, 
    payment_method_id VARCHAR(36) NOT NULL, 
    amount FLOAT NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (sale_id) REFERENCES sale(id), 
    FOREIGN KEY (payment_method_id) REFERENCES payment_method(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      `CREATE TABLE IF NOT EXISTS purchase_payment (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    purchase_id VARCHAR(36) NOT NULL, 
    payment_method_id VARCHAR(36) NOT NULL, 
    amount FLOAT NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (purchase_id) REFERENCES purchase(id), 
    FOREIGN KEY (payment_method_id) REFERENCES payment_method(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      // Cuenta corriente y movimientos
      `CREATE TABLE IF NOT EXISTS current_account (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    client_id VARCHAR(36) NOT NULL, 
    sale_id VARCHAR(36), 
    payment_id VARCHAR(36), 
    type ENUM('sale', 'payment') NOT NULL, 
    amount FLOAT NOT NULL, 
    balance FLOAT NOT NULL, 
    description TEXT, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (client_id) REFERENCES client(id), 
    FOREIGN KEY (sale_id) REFERENCES sale(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      `CREATE TABLE IF NOT EXISTS movement (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    type ENUM('income', 'expense') NOT NULL, 
    category VARCHAR(50) NOT NULL, 
    description TEXT, 
    amount FLOAT NOT NULL, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      // Transferencias de stock
      `CREATE TABLE IF NOT EXISTS transfer_stock (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    from_branch_id VARCHAR(36) NOT NULL, 
    to_branch_id VARCHAR(36) NOT NULL, 
    product_id VARCHAR(36) NOT NULL, 
    amount FLOAT NOT NULL, 
    usuario VARCHAR(100), 
    employee_id VARCHAR(36), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    device_id VARCHAR(64), 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (from_branch_id) REFERENCES branch(id), 
    FOREIGN KEY (to_branch_id) REFERENCES branch(id), 
    FOREIGN KEY (product_id) REFERENCES product(id), 
    FOREIGN KEY (employee_id) REFERENCES employee(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      // Distribución de compras
      `CREATE TABLE IF NOT EXISTS purchase_distribution (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()), 
    purchase_id VARCHAR(36) NOT NULL, 
    product_id VARCHAR(36) NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    amount FLOAT NOT NULL, 
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (purchase_id) REFERENCES purchase(id), 
    FOREIGN KEY (product_id) REFERENCES product(id), 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      // Registro de dispositivos
      `CREATE TABLE IF NOT EXISTS device_registry (
    device_id VARCHAR(64) PRIMARY KEY, 
    device_name VARCHAR(100) NOT NULL, 
    branch_id VARCHAR(36) NULL DEFAULT NULL, 
    pc_type ENUM('central', 'caja') NOT NULL, 
    platform VARCHAR(50), 
    user_agent TEXT, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    last_connection TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    active BOOLEAN DEFAULT TRUE, 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0, 
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      // Nuevas tablas para registro de cuenta corriente
      `CREATE TABLE IF NOT EXISTS current_account_log (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    user_id VARCHAR(36) NOT NULL,
    type ENUM('debt', 'credit') NOT NULL,
    amount FLOAT NOT NULL,
    note TEXT,
    actor_id VARCHAR(36),
    branch_id VARCHAR(36) NULL DEFAULT NULL,
    device_id VARCHAR(64), 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    synced TINYINT DEFAULT 0,
    deleted TINYINT DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (actor_id) REFERENCES employee(id),
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      `CREATE TABLE IF NOT EXISTS current_account_payment (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    current_account_log_id VARCHAR(36) NOT NULL,
    payment_method_id VARCHAR(36) NOT NULL,
    amount FLOAT NOT NULL,
    branch_id VARCHAR(36) NULL DEFAULT NULL,
    device_id VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    synced TINYINT DEFAULT 0,
    deleted TINYINT DEFAULT 0,
    FOREIGN KEY (current_account_log_id) REFERENCES current_account_log(id),
    FOREIGN KEY (payment_method_id) REFERENCES payment_method(id),
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      // 🔧 CORRECCIÓN TABLA FALTANTE: device_afip_config 
      // Esta tabla es usada en branch.ts pero no estaba definida en el esquema
      `CREATE TABLE IF NOT EXISTS device_afip_config (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    device_id VARCHAR(64) NOT NULL,
    branch_id VARCHAR(36) NOT NULL,
    afip_sales_point INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, 
    synced TINYINT DEFAULT 0, 
    deleted TINYINT DEFAULT 0,
    UNIQUE KEY unique_device_branch (device_id, branch_id),
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,

      // 🆕 NUEVA TABLA: app_settings - Configuración de la aplicación
      `CREATE TABLE IF NOT EXISTS app_settings (
    id VARCHAR(36) PRIMARY KEY DEFAULT (UUID()),
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT,
    description TEXT,
    branch_id VARCHAR(36) NULL,
    device_id VARCHAR(64),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    synced TINYINT DEFAULT 0,
    deleted TINYINT DEFAULT 0,
    INDEX idx_setting_key_device (setting_key, device_id),
    UNIQUE KEY unique_setting_per_device (setting_key, device_id),
    FOREIGN KEY (branch_id) REFERENCES branch(id)
  )`,
    ];