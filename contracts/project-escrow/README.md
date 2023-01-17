# Escrow

Установка зависимостей:

```bash
npm install
```

Компиляция:

```bash
npx hardhat compile
```

Запуск скриптов:

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

*Можно было бы сделать деплой в виде отдельных шагов, используя `hardhat tasks` чтобы передавать параметры, но пока так.*