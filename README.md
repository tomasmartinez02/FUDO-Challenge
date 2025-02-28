# FUDO Challenge

La API se construyo con **Ruby + Rack**, usa autenticación JWT y persiste datos en **SQLite**.

---

## Requisitos

- **Ruby 3.4.2** (se recomienda usar [RVM](https://rvm.io/rvm/install))
- **Bundler** (`gem install bundler`)
- **Docker** (opcional, para correr en contenedor)

---

## Cómo levantar el proyecto

### Opción 1: Usando Ruby directamente

1. Instalá las dependencias:
   ```sh
   bundle install
   ```
2. Iniciá la base de datos:
   ```sh
   bundle exec ruby config/database.rb
   ```
3. Levantá el servidor:
   ```sh
   bundle exec puma -p 3000
   ```

---

### Opción 2: Usando Docker

1. Construí la imagen:
   ```sh
   sudo docker build -t fudo_challenge_api .
   ```
2. Ejecutá el contenedor:
   ```sh
   sudo docker run -p 3000:3000 fudo_challenge_api
   ```

---

## Cómo correr los tests

Para ejecutar los tests con **RSpec**:

```sh
RACK_ENV=test bundle exec rspec
```

---

## Decisiones de diseño

- Se utilizó una base de datos **SQLite** para persistir productos y usuarios, debido a su configuración simple para estos casos.
- Para resolver la asincronía en la creación de productos, se utilizó un **worker** con una **cola de mensajes**. La cantidad de workers se define a través de la variable de entorno `PRODUCT_WORKERS` para evitar crear un hilo por cada procesamiento de producto y así saturar el sistema.
- Las contraseñas de los usuarios se guardan encriptadas por razones de seguridad.

---

**Autor:** Tomas Martinez  

