use CalzadosContersDB2
select*from Usuarios
-- SQL Script para ALTERAR el procedimiento almacenado SP_LoginUsuario

-- Aseg�rate de que tu tabla de usuarios y nombres de columnas coincidan
-- Columnas en tu tabla de usuarios: UserID, FirstName, LastName, Email, Password, Address, RoleID, Telefono

ALTER PROCEDURE [dbo].[SP_LoginUsuario]
    @Email NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        UserID AS id,          -- Mapea UserID a 'id' para el frontend/backend
        FirstName AS name,     -- Mapea FirstName a 'name'
        LastName AS lastname,  -- Mapea LastName a 'lastname'
        Email,                 -- Ya es 'Email'
        Password AS Contrasena, -- Mapea Password a 'Contrasena' (como lo espera el backend)
        Address AS Direccion,  -- Mapea Address a 'Direccion'
        (SELECT RoleName FROM Roles WHERE RoleID = U.RoleID) AS Rol, -- Asume una tabla Roles
        Telefono               -- Ya es 'Telefono'
    FROM
        Usuarios AS U -- Reemplaza 'Users' si tu tabla se llama diferente
    WHERE
        Email = @Email;
END;
--------------------------
ALTER PROCEDURE [dbo].[SP_RegistrarUsuario]
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Telefono NVARCHAR(20),
    @Direccion NVARCHAR(255),
    @Email NVARCHAR(255),
    @Contrasena NVARCHAR(255) -- Este par�metro recibir� el hash de bcrypt
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar si el correo electr�nico ya est� registrado
    IF EXISTS (SELECT 1 FROM Usuarios WHERE Email = @Email)
    BEGIN
        RAISERROR('Este correo electr�nico ya est� registrado.', 16, 1);
        RETURN;
    END;

    INSERT INTO Usuarios(
        FirstName,
        LastName,
        Telefono,
        Address,
        Email,
        Password, -- Aqu� se guardar� el hash de bcrypt tal cual lo recibe
        RoleID,   -- Asume un RoleID por defecto, ej. 1 para Cliente
        Created_At,
        Updated_At
    )
    VALUES (
        @Nombre,
        @Apellido,
        @Telefono,
        @Direccion,
        @Email,
        @Contrasena, -- Se inserta el hash de bcrypt directamente
        1,            -- Asume 1 es el RoleID para 'Cliente'
        GETDATE(),
        GETDATE()
    );

    SELECT SCOPE_IDENTITY() AS NuevoIDUsuario; -- Devuelve el ID del nuevo usuario
END;
-------------------------
UPDATE [dbo].[Usuarios] -- *** �IMPORTANTE! Reemplaza '[dbo].[Usuarios]' con el nombre REAL de tu tabla de usuarios ***
SET
    RoleID = 2, -- Asumiendo que 2 es el RoleID para 'Administrador'
                -- Verifica este valor en tu tabla de roles o en tu esquema.
    Updated_At = GETDATE()
WHERE
    Email = 'admin@conters.com'; -- Reemplaza con el email del usuario que registraste

-- Opcional: Verifica el resultado
SELECT UserID, FirstName, Email, RoleID, Password FROM [dbo].[Usuarios] WHERE Email = 'admin@conters.com';
----------------------------
-- SQL Script para CREAR/ALTERAR el procedimiento almacenado SP_ObtenerRoleIDPorNombre
-- Asume que tienes una tabla 'Roles' con columnas 'RoleID' y 'RoleName'.

IF OBJECT_ID('SP_ObtenerRoleIDPorNombre', 'P') IS NOT NULL
    DROP PROCEDURE SP_ObtenerRoleIDPorNombre;
GO

CREATE PROCEDURE [dbo].[SP_ObtenerRoleIDPorNombre]
    @RoleName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RoleID FROM Roles WHERE RoleName = @RoleName;
END;
GO

-- SQL Script para CREAR/ALTERAR el procedimiento almacenado SP_ActualizarRolUsuario
-- Asume que tienes una tabla 'Usuarios' (o el nombre real de tu tabla de usuarios)
-- con columnas 'UserID' y 'RoleID'.

IF OBJECT_ID('SP_ActualizarRolUsuario', 'P') IS NOT NULL
    DROP PROCEDURE SP_ActualizarRolUsuario;
GO

CREATE PROCEDURE [dbo].[SP_ActualizarRolUsuario]
    @UserID INT,
    @NewRoleID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que el UserID existe
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuarios] WHERE UserID = @UserID) -- *** �IMPORTANTE! Nombre de tu tabla de usuarios ***
    BEGIN
        RAISERROR('Usuario no encontrado.', 16, 1);
        RETURN;
    END;

    -- Validar que el NewRoleID existe
    IF NOT EXISTS (SELECT 1 FROM Roles WHERE RoleID = @NewRoleID)
    BEGIN
        RAISERROR('Rol inv�lido.', 16, 1);
        RETURN;
    END;

    UPDATE [dbo].[Usuarios] -- *** �IMPORTANTE! Nombre de tu tabla de usuarios ***
    SET
        RoleID = @NewRoleID,
        Updated_At = GETDATE()
    WHERE
        UserID = @UserID;
END;
GO
----------------------------------------------------------
use CalzadosContersDB2
ALTER PROCEDURE [dbo].[SP_ObtenerRoleIDPorNombre]
    @RoleName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT RoleID FROM [dbo].[Roles] WHERE RoleName = @RoleName;
END;
GO

-- SQL Script para ALTERAR el procedimiento almacenado SP_ActualizarRolUsuario
-- Asume que tu tabla de usuarios se llama '[dbo].[Usuarios]' (o el nombre que uses).
-- Y que tu tabla de roles se llama '[dbo].[Roles]' (o el nombre que uses).

ALTER PROCEDURE [dbo].[SP_ActualizarRolUsuario]
    @UserID INT,
    @NewRoleID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar que el UserID existe
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Usuarios] WHERE UserID = @UserID) -- Aseg�rate que '[dbo].[Usuarios]' sea el nombre correcto de tu tabla de usuarios
    BEGIN
        RAISERROR('Usuario no encontrado.', 16, 1);
        RETURN;
    END;

    -- Validar que el NewRoleID existe en tu tabla de roles
    IF NOT EXISTS (SELECT 1 FROM [dbo].[Roles] WHERE RoleID = @NewRoleID) -- *** �IMPORTANTE! Reemplaza 'TU_NOMBRE_DE_TABLA_DE_ROLES' ***
    BEGIN
        RAISERROR('Rol inv�lido.', 16, 1);
        RETURN;
    END;

    UPDATE [dbo].[Usuarios] -- Aseg�rate que '[dbo].[Usuarios]' sea el nombre correcto de tu tabla de usuarios
    SET
        RoleID = @NewRoleID,
        Updated_At = GETDATE()
    WHERE
        UserID = @UserID;
END;
GO
-----------------
exec SP_ObtenerTodosLosUsuariosParaAdmin
select*from Productos
select*from Inventario
-----------------------
----------------------------------------------
-- SP_RegistrarPedido
-- Correcci�n: Lectura correcta de ProductID del JSON.

ALTER PROCEDURE SP_RegistrarPedido
    @ID_Usuario INT = NULL,
    @DireccionEnvio VARCHAR(255),
    @TelefonoEnvio VARCHAR(20),
    @MetodoPago VARCHAR(50),
    @ItemsJson NVARCHAR(MAX),
    @DeliveryOptionID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NuevoIDPedido INT;
    DECLARE @OptionName VARCHAR(100);
    DECLARE @OptionCost DECIMAL(10,2);
    DECLARE @EstimatedDeliveryTimeText VARCHAR(100);

    -- Aseg�rate de que [dbo].[OpcionesEntrega] sea el nombre correcto de tu tabla
    SELECT
        @OptionName = OptionName,
        @OptionCost = Cost,
        @EstimatedDeliveryTimeText = CAST(EstimatedDays AS VARCHAR(10)) + ' d�as h�biles'
    FROM [dbo].[OpcionesEntrega] WITH (NOLOCK) -- A�adido WITH (NOLOCK)
    WHERE DeliveryOptionID = @DeliveryOptionID;

    IF @OptionName IS NULL
    BEGIN
        THROW 50000, 'Opci�n de entrega seleccionada no es v�lida o no existe.', 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[�rdenes] (UserID, OrderDate, PaymentMethod, OrderStatus, DeliveryOptionID, DeliveryCost, EstimatedDeliveryTime, DeliveryAddress, TelefonoEnvio, Created_At, Updated_At)
        VALUES (ISNULL(@ID_Usuario, (SELECT TOP 1 UserID FROM [dbo].[Usuarios] WITH (NOLOCK) WHERE RoleID = (SELECT RoleID FROM [dbo].[Roles] WITH (NOLOCK) WHERE RoleName = 'Cliente'))), -- A�adido WITH (NOLOCK)
                GETDATE(), @MetodoPago, 'Pendiente de Pago', @DeliveryOptionID, @OptionCost, @EstimatedDeliveryTimeText, @DireccionEnvio, @TelefonoEnvio, GETDATE(), GETDATE());

        SET @NuevoIDPedido = SCOPE_IDENTITY();

        IF ISJSON(@ItemsJson) = 0
        BEGIN
            THROW 50000, 'El JSON de �tems es inv�lido.', 1;
        END;

        INSERT INTO [dbo].[�tems_de_Orden] (OrderID, ProductID, Quantity, UnitPrice) -- Aseg�rate que [dbo].[�tems_de_Orden] es el nombre correcto
        SELECT
            @NuevoIDPedido,
            JSON_VALUE(items.value, '$.ProductID'), -- <-- �CORRECCI�N CR�TICA AQU�! A '$.ProductID'
            JSON_VALUE(items.value, '$.Cantidad'),   -- <-- �CORRECCI�N AQU�! A '$.Cantidad'
            JSON_VALUE(items.value, '$.price')      -- Asumiendo que 'price' viene del frontend. Si no, ajustar.
        FROM OPENJSON(@ItemsJson) AS items;

        -- El siguiente bloque tambi�n necesita usar ProductID y Cantidad
        IF EXISTS (
            SELECT 1
            FROM OPENJSON(@ItemsJson)
            WITH (
                ProductID INT '$.ProductID', -- <-- �CORRECCI�N AQU�!
                Cantidad INT '$.Cantidad'    -- <-- �CORRECCI�N AQU�!
            ) AS carrito
            JOIN [dbo].[Inventario] i WITH (NOLOCK) ON carrito.ProductID = i.ProductID -- Aseg�rate que [dbo].[Inventario] es el nombre correcto y a�adido NOLOCK
            WHERE carrito.Cantidad > i.StockQuantity
        )
        BEGIN
            THROW 50000, 'No hay suficiente stock para uno o m�s productos en el carrito.', 1;
        END;

        UPDATE i
        SET i.StockQuantity = i.StockQuantity - carrito.Cantidad, -- <-- �CORRECCI�N AQU�!
            i.LastStockUpdate = GETDATE()
        FROM [dbo].[Inventario] i WITH (NOLOCK) -- A�adido NOLOCK
        JOIN OPENJSON(@ItemsJson)
        WITH (
            ProductID INT '$.ProductID', -- <-- �CORRECCI�N AQU�!
            Cantidad INT '$.Cantidad'    -- <-- �CORRECCI�N AQU�!
        ) AS carrito ON i.ProductID = carrito.ProductID;

        COMMIT TRANSACTION;
        SELECT @NuevoIDPedido AS NuevoIDPedido;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
PRINT 'SP_RegistrarPedido creado/actualizado.';