# mipt-ethereum

Домашние работы и проект по курсу "Ethereum" 9 семестра.

# Проект Escrow

### Установка зависимостей:

```bash
npm install
```

### Компиляция:

```bash
npx hardhat compile
```

### Запуск скриптов:

```bash
# в отдельном терминале
npx hardhat node
```

```bash
npx hardhat run --network localhost scripts/<script_name>.js
```
где `<script_name>.js` может быть одним из:
* `deploy_impl.js` - деплоит только реализацию
* `deploy_factory.js` - деплоит реализацию и фабрику
* `deploy_example.js` - деплоит реализацию, фабрику, и с помощью фабрики создаёт пример готового для использования прокси

### Запуск тестов:
```bash
npx hardhat test test/escrow.test.js

# с подсчётом покрытия
npx hardhat coverage --testfiles test/escrow.test.js
```