# Инфраструктура

package.json содержит 2 команды:
- `build` - копирует файлы из папки `src` (index.html) в папку `dist` 
- `test` - выполняет фейковые тесты

Для того чтобы сборка выполнилась, нужно добавить тег и запушить его в репозиторий. 

Код скрипта, создающего тикет yandex трекере, находится в файле `.github/actions/yandex-tracker/entrypoint.sh` 
