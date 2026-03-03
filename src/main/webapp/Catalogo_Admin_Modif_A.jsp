<%@ page import="basesita.Base" %> <%@ page import="java.sql.ResultSet" %> <%@
page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Gestión de Catálogo de Regalos</title>
    <link rel="stylesheet" href="Estilos/Catalogo.css" />
    <link rel="stylesheet" href="Estilos/Cat_Admin_Modi.css" />
  </head>
  <body>
    <% String busqueda = request.getParameter("busqueda"); if (busqueda == null)
    busqueda = ""; %>

    <!-- Encabezado -->
    <div id="EncabezadoId"></div>
    <script src="scripts/Encabezado.js"></script>

    <main id="product-container" class="product-container2">
      <header>
        <h1>Gestión de Catálogo de Regalos para Eventos</h1>
      </header>

      <div class="Container_form">
        <!-- Formulario -->
        <section class="form-section">
          <h2>Formulario de Administración</h2>
          <form
            id="catalog-form"
            action="Catalogo_Admin_Modif_B.jsp?busqueda=<%=busqueda%>"
            method="POST"
          >
            <input
              type="text"
              id="product-id"
              hidden="hidden"
              name="idregalo"
            />
            <button type="button" id="limpiarFormulario">Limpiar</button>

            <div class="form-group">
              <label for="product-name">Nombre del producto:</label>
              <input
                type="text"
                id="product-name"
                placeholder="Escribe el nombre del producto"
                name="nombre"
                required
              />
            </div>

            <div class="form-group">
              <label for="product-description">Descripción:</label>
              <textarea
                id="product-description"
                placeholder="Escribe una breve descripción"
                name="descripcion"
                required
              ></textarea>
            </div>

            <div class="form-group">
              <label for="product-price">Precio:</label>
              <input
                type="number"
                id="product-price"
                placeholder="Ej. 199.99"
                step="0.01"
                name="precio"
                required
              />
            </div>

            <div class="form-group">
              <label for="product-quantity">Existencias:</label>
              <input
                type="number"
                id="product-quantity"
                placeholder="Ej. 5"
                step="1"
                name="hay"
                required
              />
            </div>

            <div class="form-group">
              <label for="product-category">Categoría:</label>
              <select id="product-category" name="categoria" required>
                <option value="">Selecciona una categoría</option>
                <option value="Boda">Boda</option>
                <option value="XV_Años">XV Años</option>
                <option value="Bautizos">Bautizos</option>
                <option value="Infantiles">Infantiles</option>
                <option value="Para_el">Para él</option>
                <option value="Para_ella">Para ella</option>
              </select>
            </div>

            <div class="form-group">
              <label for="product-image">Imagen del producto (URL):</label>
              <input
                type="url"
                id="product-image"
                placeholder="https://example.com/imagen.jpg"
                name="imagen"
                required
              />
            </div>

            <div class="form-actions">
              <button type="submit" name="botons" id="subir" disabled>
                Llena todos los campos para crear
              </button>
              <button
                type="submit"
                name="botons"
                value="eliminar"
                id="delete-btn"
                disabled
              >
                Selecciona un producto para modificar o eliminar
              </button>
            </div>
          </form>
        </section>
      </div>

      <section class="catalog-section">
        <h2>Catálogo de Productos</h2>
        <form method="post" action="Catalogo_Admin_Modif_A.jsp">
          <div class="search-bar">
            <input
              type="text"
              name="busqueda"
              id="search-bar"
              placeholder="Buscar producto..."
            />
          </div>
        </form>

        <div id="product-catalog" class="product-catalog">
          <!-- Productos generados por el servidor -->
          <% Base bd = new Base(); try { bd.conectar(); String strQry = "select
          imagen, nombre, categoria, descripcion, precio, existencias, id_regalo
          from producto where nombre like '%"+busqueda+"%';"; ResultSet rs =
          bd.consulta(strQry); while (rs.next()) { // Extraer valores y proteger
          comillas dobles en los atributos (mínimo) String imagen =
          rs.getString(1) == null ? "" : rs.getString(1).replace("\"","&quot;");
          String nombre = rs.getString(2) == null ? "" :
          rs.getString(2).replace("\"","&quot;"); String categoria =
          rs.getString(3) == null ? "" : rs.getString(3).replace("\"","&quot;");
          String descripcion = rs.getString(4) == null ? "" :
          rs.getString(4).replace("\"","&quot;"); String precio =
          rs.getString(5) == null ? "" : rs.getString(5).replace("\"","&quot;");
          String existencias = rs.getString(6) == null ? "" :
          rs.getString(6).replace("\"","&quot;"); String idRegalo =
          rs.getString(7) == null ? "" : rs.getString(7).replace("\"","&quot;");
          %>

          <div class="product-card">
            <img
              src="<%=imagen%>"
              alt="Imagen producto"
              class="product-image"
            />
            <h2 class="product-name"><%=nombre%></h2>
            <p class="product-category">
              <strong>Categoría:</strong> <%=categoria%>
            </p>
            <p class="product-description"><%=descripcion%></p>
            <p class="product-description">
              <strong>Existencias:</strong> <%=existencias%>
            </p>
            <p class="product-price"><strong>Precio:</strong> $<%=precio%></p>

            <!-- Botón con data-* que contiene los datos del producto -->
            <button
              class="add-to-cart-btn"
              id="button<%=idRegalo%>"
              type="button"
              data-id="<%=idRegalo%>"
              data-name="<%=nombre%>"
              data-desc="<%=descripcion%>"
              data-price="<%=precio%>"
              data-qty="<%=existencias%>"
              data-cat="<%=categoria%>"
              data-img="<%=imagen%>"
            >
              Seleccionar
            </button>
          </div>

          <% } bd.cierraConexion(); } catch (Exception ex) { // Mejor enviar al
          log; se muestra por simplicidad out.println("
          <p>Error: " + ex.getMessage() + "</p>
          "); } %>
        </div>
      </section>

      <!-- SCRIPTS: una sola función para llenar el formulario -->
      <script>
        // Asignar el valor de búsqueda al campo
        document.getElementById("search-bar").value = "<%=busqueda.replace("\"","\\\"")%>";

        // Función única que llena el formulario a partir del botón (data-attrs)
        function fillFormFromButton(button) {
          if (!button || !button.dataset) return;
          const d = button.dataset;
          document.getElementById('product-id').value = d.id || '';
          document.getElementById('product-name').value = d.name || '';
          document.getElementById('product-description').value = d.desc || '';
          document.getElementById('product-price').value = d.price || '';
          document.getElementById('product-quantity').value = d.qty || '';
          document.getElementById('product-category').value = d.cat || '';
          document.getElementById('product-image').value = d.img || '';
          verificarCampos(); // actualizar estado de botones
        }

        // Manejo de selección visual/estado de botones
        let ultimoBotonPresionado = null;

        // Añadir listeners a todos los botones generados
        document.querySelectorAll('button[id^="button"]').forEach((button) => {
          button.addEventListener("click", function () {
            // Llamar a la función que llena el formulario
            fillFormFromButton(this);

            // Habilitar el botón previamente deshabilitado (si existe)
            if (ultimoBotonPresionado) {
              ultimoBotonPresionado.disabled = false;
              ultimoBotonPresionado.innerText = "Seleccionar";
            }

            // Deshabilitar el botón presionado
            this.disabled = true;
            this.innerText = "Seleccionado";

            // Actualizar el rastreador del último botón
            ultimoBotonPresionado = this;
          });
        });

        // Botón limpiar
        const botonLimpiar = document.getElementById("limpiarFormulario");
        const formulario = document.getElementById("catalog-form");
        botonLimpiar.addEventListener("click", function () {
          formulario.reset();
          verificarCampos();
          if (ultimoBotonPresionado) {
            ultimoBotonPresionado.disabled = false;
            ultimoBotonPresionado.innerText = "Seleccionar";
            ultimoBotonPresionado = null;
          }
        });

        // Control de habilitado de botones (se toma el mismo código que tenías, con pequeñas correcciones)
        const botonEnviar = document.getElementById("subir");
        const botonEliminar = document.getElementById("delete-btn");
        const camposRequeridos = [
          document.getElementById("product-name"),
          document.getElementById("product-description"),
          document.getElementById("product-price"),
          document.getElementById("product-quantity"),
          document.getElementById("product-category"),
          document.getElementById("product-image")
        ];
        const idproducto = document.getElementById("product-id");

        function verificarCampos() {
          let todosLlenos = true;
          camposRequeridos.forEach((campo) => {
            if (!campo) { todosLlenos = false; return; }
            if (campo.tagName === "SELECT") {
              if (campo.value === "") todosLlenos = false;
            } else {
              if (campo.value.trim() === "") todosLlenos = false;
            }
          });

          if (idproducto.value.trim() === "") {
            // Modo crear
            if (!todosLlenos) {
              botonEnviar.disabled = true;
              botonEnviar.innerText = "Llena todos los campos para crear";
              botonEliminar.disabled = true;
              botonEliminar.innerText = "Selecciona un producto para modificar o eliminar";
            } else {
              botonEnviar.disabled = false;
              botonEnviar.innerText = "Crear";
              botonEnviar.value = "crear";
              botonEliminar.disabled = true;
              botonEliminar.innerText = "Selecciona un producto para modificar o eliminar";
            }
          } else {
            // Modo modificar/eliminar
            if (!todosLlenos) {
              botonEnviar.disabled = true;
              botonEnviar.innerText = "Llena todos los campos para modificar";
              botonEliminar.disabled = false;
              botonEliminar.innerText = "Eliminar";
            } else {
              botonEnviar.disabled = false;
              botonEnviar.innerText = "Modificar";
              botonEnviar.value = "modificar";
              botonEliminar.disabled = false;
              botonEliminar.innerText = "Eliminar";
            }
          }
        }

        // Añadir event listeners a cada campo requerido
        camposRequeridos.forEach((campo) => {
          if (!campo) return;
          campo.addEventListener("input", verificarCampos);
          if (campo.tagName === "SELECT") campo.addEventListener("change", verificarCampos);
        });
        idproducto.addEventListener("input", verificarCampos);

        // Llamada inicial para actualizar botones según estado actual
        verificarCampos();
      </script>

      <script src="scripts.js"></script>
    </main>
  </body>
</html>
