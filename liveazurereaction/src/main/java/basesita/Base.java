package basesita;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * Clase para manejar la conexión a la base de datos.
 * Mejora sobre la versión original: carga del driver con Class.forName(...),
 * manejo adecuado de excepciones y recursos, y comprobaciones.
 *
 * NOTA: evita hardcodear credenciales en código de producción.
 */
public class Base {

    private String usrBD;
    private String passBD;
    private String urlBD;
    private String driverClassName;
    private Connection conn = null;
    // Statement usado para consultas que devuelven ResultSet; se mantiene abierto
    // hasta que se llame a cerrarEstancia() o cierraConexion()
    private Statement estancia;

    public Base() {
        // Valores por defecto. Ajusta según tu entorno.
        this.usrBD = "adminpicsa"; // en Azure suele ser user@servername
        this.passBD = "AP_123Si";
        // Para Azure se recomienda sslMode=REQUIRED
        this.urlBD = "jdbc:mysql://mypicsareaction.mysql.database.azure.com:3306/chamba?sslMode=REQUIRED&serverTimezone=UTC";
        this.driverClassName = "com.mysql.cj.jdbc.Driver";
    }

    /* Setters */
    public void setUsuarioBD(String usuario) {
        this.usrBD = usuario;
    }

    public void setPassBD(String pass) {
        this.passBD = pass;
    }

    public void setUrlBD(String url) {
        this.urlBD = url;
    }

    public void setDriverClassName(String driverClassName) {
        this.driverClassName = driverClassName;
    }

    public void setConn(Connection conn) {
        this.conn = conn;
    }

    /* Comprueba si hay conexión activa */
    /**
     * @return
     */
    public boolean isConnected() {
        try {
            return this.conn != null && !this.conn.isClosed();
        } catch (SQLException e) {
            return false;
        }
    }

    /**
     * Conecta a la base de datos.
     * Lanza SQLException si falla la conexión.
     */
    public void conectar() throws SQLException {
        try {
            // Cargar la clase del driver (no es estrictamente necesario si el JAR está en classpath,
            // pero garantiza compatibilidad en algunos entornos)
            Class.forName(this.driverClassName);

            // Conexión: DriverManager lanzará SQLException si algo falla
            this.conn = DriverManager.getConnection(this.urlBD, this.usrBD, this.passBD);
        } catch (ClassNotFoundException cnfe) {
            // Driver no encontrado en el classpath
            cnfe.printStackTrace();
            throw new SQLException("Driver JDBC no encontrado: " + this.driverClassName, cnfe);
        } catch (SQLException sqle) {
            sqle.printStackTrace();
            throw sqle; // re-lanzar para que el llamador lo maneje
        } catch (Exception ex) {
            ex.printStackTrace();
            throw new SQLException("Error inesperado al conectar: " + ex.getMessage(), ex);
        }
    }

    /**
     * Cierra la conexión y cualquier Statement abierto para consultas.
     */
    public void cierraConexion() {
        // Cerrar estancia (Statement usado por consulta que devuelve ResultSet)
        cerrarEstancia();
        if (this.conn != null) {
            try {
                if (!this.conn.isClosed()) {
                    this.conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                this.conn = null;
            }
        }
    }

    /**
     * Cierra el Statement (estancia) usado en consulta().
     * Si una ResultSet está en uso, cerrarla antes o después según tu flujo.
     */
    public void cerrarEstancia() {
        if (this.estancia != null) {
            try {
                this.estancia.close();
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                this.estancia = null;
            }
        }
    }

    /**
     * Ejecuta una instrucción INSERT y devuelve el número de filas afectadas.
     * Usa try-with-resources para cerrar el Statement automáticamente.
     */
    public int insertar(String inserta) throws SQLException {
        ensureConnected();
        try (Statement st = this.conn.createStatement()) {
            return st.executeUpdate(inserta);
        }
    }

    /**
     * Ejecuta una instrucción DELETE y devuelve el número de filas afectadas.
     */
    public int borrar(String borra) throws SQLException {
        ensureConnected();
        try (Statement st = this.conn.createStatement()) {
            return st.executeUpdate(borra);
        }
    }

    /**
     * Ejecuta una consulta SELECT y devuelve el ResultSet.
     * IMPORTANTE: la responsabilidad de cerrar el ResultSet recae en el llamador.
     * Este método crea un Statement y lo asigna a 'estancia' para permitir cerrarlo
     * posteriormente con cerrarEstancia() o cierraConexion().
     */
    public ResultSet consulta(String consulta) throws SQLException {
        ensureConnected();
        // Si ya hay una estancia abierta, ciérrala primero para evitar fugas
        cerrarEstancia();

        this.estancia = this.conn.createStatement();
        return this.estancia.executeQuery(consulta);
    }

    /**
     * Ejecuta una instrucción UPDATE y devuelve el número de filas afectadas.
     */
    public int edita(String edita) throws SQLException {
        ensureConnected();
        try (Statement st = this.conn.createStatement()) {
            return st.executeUpdate(edita);
        }
    }

    /* Verifica que haya conexión establecida y válida */
    private void ensureConnected() throws SQLException {
        if (this.conn == null || this.conn.isClosed()) {
            throw new SQLException("No hay conexión a la base de datos. Llama primero a conectar().");
        }
    }
}