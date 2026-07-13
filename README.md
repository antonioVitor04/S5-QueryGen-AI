<!--TÍTULO-->
# Sistema QueryGen AI


<!--DESCRIÇÃO-->
> Sistema desenvolvido para a empresa Klabin.<br/>
> O sistema consiste em automatizar a criação de scripts para extração e visualização de dados do SAP, utilizando IA para interpretar as necessidades do usuário e gerar consultas prontas para análises e dashboards no Power BI.


<!--STATUS-->
## Status
> ✔ Concluído.


<!--FUNCIONALIDADES-->
## Funcionalidades 
````
Usuário (Com Login):
    . Gerar Scripts SQL
    . Visualizar Histórico Scripts SQL
    . Comparar Scripts SQL
````


<!--TECNOLOGIAS-->
## Tecnologias
| <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/dart/dart-original.svg" width="40"/> | <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/flutter/flutter-original.svg" width="40"/> | <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/nodejs/nodejs-original.svg" width="40"/> | <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/mysql/mysql-original.svg" width="40"/> | <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/figma/figma-original.svg" width="40"/> |
| ---------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| Dart | Flutter | Node.js | MySQL | Figma |


<!--PROTÓTIPO-->
## Protótipo
[![](https://img.shields.io/badge/Figma--5C5C5C?logo=figma&logoColor=white)](https://www.figma.com/design/ioXDKEKEnj38tbVWfrdGZk/S5-QueryGen-AI?node-id=0-1&t=vDg1SB3WvALoOgAt-1)


<!--PARTICIPANTES-->
## Participantes
| Nome                              |
|-----------------------------------|
| Antônio Vítor Bozzo de Napoli     |
| Eduardo de Bodas                  |
| José Henrique Villanueva Malavazi |
| Leonardo Kazushi Hideshima	      |
| Luan Camara Lopes                 | 
| Victor Hugo Pinho                 | 


<!--DEPENDÊNCIAS-->
## Dependência
````
bcrypt       | ^6.0.0  | Hashing de senhas para segurança
cors         | ^2.8.6  | Habilita CORS para requisições entre origens
dotenv       | ^17.3.1 | Gerenciamento de variáveis de ambiente
express      | ^5.2.1  | Framework para criação de servidores web e APIs
jsonwebtoken | ^9.0.3  | Geração e verificação de tokens JWT
mysql2       | ^3.20.0 | Driver para conexão e consultas com banco de dados MySQL
nodemailer   | ^8.0.4  | Envio de e-mails a partir do Node.js
````


<!--COMO UTILIZAR-->
## Como Utilizar
```
Requisitos:
    . Node.js 18+ para executar o backend
    . npm como gerenciador de pacotes
    . MySQL 8.0+ para banco de dados relacional
    . Flutter SDK 3.10+ para executar o frontend
    . Dart SDK (incluso no Flutter)
    . IDE (VS Code recomendado)

Execução:
    1. Clone o repositório                          | git clone https://github.com/antonioVitor04/S5-QueryGen-AI

    2. Navegue até o diretório do projeto           | cd S5-QueryGen-AI

    3. Instale as dependências do backend           | cd backend
                                                    | npm install

    4. Configure as variáveis de ambiente           | PORT=3000
                                                    | DB_HOST=localhost
                                                    | DB_USER=root
                                                    | DB_PASSWORD=sua_senha
                                                    | DB_NAME=nome-do-banco
                                                    | JWT_SECRET=sua_chave_secreta

    5. Inicialize o backend                         | cd backend
                                                    | npm run dev

    6. Execute o frontend (Flutter)                 | cd query_gen
                                                    | flutter pub get
                                                    | flutter run
```


<!--CONTRIBUIÇÃO-->
## Contribuição
````
1. Fork               | Crie uma cópia do repositório no seu perfil

2. Clone              | git clone https://github.com/antonioVitor04/S5-QueryGen-AI

3. Crie uma Branch    | git checkout -b minha-branch

4. Faça as Alterações | Edite os arquivos e teste.

5. Commit e Push      | git add .
                      |	git commit -m "Descrição das alterações" 
                      |	git push origin minha-branch

6. Pull Request       | Solicite a inclusão de suas mudanças no repositório original.
````


<!--ESTRUTURA DE PASTAS-->
## Estrutura de Pastas
````
├── backend/
│   ├── alter.js
│   ├── alter_usuarios.js
│   ├── index.js
│   ├── package.json
│   ├── seed.js
│   ├── setup.js
│   ├── src/
│   │   ├── controllers/
│   │   │   ├── authController.js
│   │   │   ├── recoveryController.js
│   │   │   ├── scriptController.js
│   │   │   └── userController.js
│   │   ├── db/
│   │   │   ├── connection.js
│   │   │   └── migrations/
│   │   │       ├── 001_create_tables.sql
│   │   │       └── 002_sap_tables.sql
│   │   ├── middleware/
│   │   │   ├── auth.js
│   │   │   └── rateLimiter.js
│   │   ├── routes/
│   │   │   ├── auth.js
│   │   │   ├── history.js
│   │   │   ├── recovery.js
│   │   │   ├── scripts.js
│   │   │   └── user.js
│   │   ├── sap/
│   │   │   ├── dictionary.js
│   │   │   └── sqlBuilder.js
│   │   └── services/
│   │       └── emailService.js
│   └── tests/
│       └── sqlBuilder.test.js
├── query_gen/
│   ├── analysis_options.yaml
│   ├── pubspec.lock
│   ├── pubspec.yaml
│   ├── .metadata
│   ├── android/
│   │   ├── build.gradle.kts
│   │   ├── gradle.properties
│   │   ├── settings.gradle.kts
│   │   ├── app/
│   │   │   ├── build.gradle.kts
│   │   │   └── src/
│   │   │       ├── debug/
│   │   │       │   └── AndroidManifest.xml
│   │   │       ├── main/
│   │   │       │   ├── AndroidManifest.xml
│   │   │       │   ├── kotlin/
│   │   │       │   │   └── com/
│   │   │       │   │       └── example/
│   │   │       │   │           └── query_gen/
│   │   │       │   │               └── MainActivity.kt
│   │   │       │   └── res/
│   │   │       │       ├── drawable/
│   │   │       │       │   └── launch_background.xml
│   │   │       │       ├── drawable-v21/
│   │   │       │       │   └── launch_background.xml
│   │   │       │       ├── values/
│   │   │       │       │   └── styles.xml
│   │   │       │       └── values-night/
│   │   │       │           └── styles.xml
│   │   │       └── profile/
│   │   │           └── AndroidManifest.xml
│   │   └── gradle/
│   │       └── wrapper/
│   │           └── gradle-wrapper.properties
│   ├── ios/
│   │   ├── Flutter/
│   │   │   ├── AppFrameworkInfo.plist
│   │   │   ├── Debug.xcconfig
│   │   │   └── Release.xcconfig
│   │   ├── Runner/
│   │   │   ├── AppDelegate.swift
│   │   │   ├── Info.plist
│   │   │   ├── Runner-Bridging-Header.h
│   │   │   ├── Assets.xcassets/
│   │   │   │   ├── AppIcon.appiconset/
│   │   │   │   │   └── Contents.json
│   │   │   │   └── LaunchImage.imageset/
│   │   │   │       ├── README.md
│   │   │   │       └── Contents.json
│   │   │   └── Base.lproj/
│   │   │       ├── LaunchScreen.storyboard
│   │   │       └── Main.storyboard
│   │   └── RunnerTests/
│   │       └── RunnerTests.swift
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   │   ├── chart_screen.dart
│   │   │   ├── comparison_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   ├── history_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── main_shell.dart
│   │   │   ├── privacy_policy_screen.dart
│   │   │   └── terms_of_use_screen.dart
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   └── auth_service.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_theme.dart
│   │   │   └── theme_notifier.dart
│   │   ├── utils/
│   │   │   ├── legal_texts.dart
│   │   │   ├── responsive.dart
│   │   │   └── routes.dart
│   │   └── widgets/
│   │       ├── app_header.dart
│   │       ├── chart_widget.dart
│   │       ├── data_table_widget.dart
│   │       ├── profile_modal.dart
│   │       ├── graphics/
│   │       │   ├── activity_bars_widget.dart
│   │       │   ├── bar_chart_widget.dart
│   │       │   ├── donut_chart_widget.dart
│   │       │   ├── line_chart_widget.dart
│   │       │   └── stat_pill_widget.dart
│   │       └── navbar/
│   │           └── navbar.dart
│   ├── linux/
│   │   ├── CMakeLists.txt
│   │   ├── flutter/
│   │   │   ├── CMakeLists.txt
│   │   │   ├── generated_plugin_registrant.cc
│   │   │   ├── generated_plugin_registrant.h
│   │   │   └── generated_plugins.cmake
│   │   └── runner/
│   │       ├── CMakeLists.txt
│   │       ├── main.cc
│   │       ├── my_application.cc
│   │       └── my_application.h
│   ├── macos/
│   │   ├── Flutter/
│   │   │   ├── Flutter-Debug.xcconfig
│   │   │   ├── Flutter-Release.xcconfig
│   │   │   └── GeneratedPluginRegistrant.swift
│   │   ├── Runner/
│   │   │   ├── AppDelegate.swift
│   │   │   ├── DebugProfile.entitlements
│   │   │   ├── Info.plist
│   │   │   ├── MainFlutterWindow.swift
│   │   │   ├── Release.entitlements
│   │   │   ├── Assets.xcassets/
│   │   │   │   └── AppIcon.appiconset/
│   │   │   │       └── Contents.json
│   │   │   ├── Base.lproj/
│   │   │   │   └── MainMenu.xib
│   │   │   └── Configs/
│   │   │       ├── AppInfo.xcconfig
│   │   │       ├── Debug.xcconfig
│   │   │       ├── Release.xcconfig
│   │   │       └── Warnings.xcconfig
│   │   └── RunnerTests/
│   │       └── RunnerTests.swift
│   ├── web/
│   │   ├── acessibilidade_plugin.js
│   │   ├── flutter_bootstrap.js
│   │   ├── index.html
│   │   └── manifest.json
│   └── windows/
│       ├── CMakeLists.txt
│       ├── flutter/
│       │   ├── CMakeLists.txt
│       │   ├── generated_plugin_registrant.cc
│       │   ├── generated_plugin_registrant.h
│       │   └── generated_plugins.cmake
│       └── runner/
│           ├── CMakeLists.txt
│           ├── flutter_window.cpp
│           ├── flutter_window.h
│           ├── main.cpp
│           ├── resource.h
│           ├── runner.exe.manifest
│           ├── Runner.rc
│           ├── utils.cpp
│           ├── utils.h
│           ├── win32_window.cpp
│           └── win32_window.h
├── .DS_Store
├── LICENSE
└── README.md
````


<!--ESTATÍSTICAS-->
## Estatísticas
![](https://visitor-badge.laobi.icu/badge?page_id=antonioVitor04.S5-QueryGen-AI)
![Tamanho do Repositório](https://img.shields.io/github/repo-size/antonioVitor04/S5-QueryGen-AI)
![Linguagens](https://img.shields.io/github/languages/top/antonioVitor04/S5-QueryGen-AI)


<!--LICENÇA-->
## Licença
[Veja a licença](https://github.com/antonioVitor04/S5-QueryGen-AI?tab=License-1-ov-file)
