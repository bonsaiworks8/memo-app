# memo-app

## データベースの準備

各OS環境に合わせて`PostgreSQL`をインストールしてください。
このREADMEでは`M1 mac`でのPostgreSQLインストール手順を示します。
`PostgreSQL`のインストールが終わった方はユーザーの作成から読んでください。

### Homebrewのインストール
`Homebrew`のインストールが終わっていない方はコマンドラインから次のコマンドを実行してインストールしてください。
```
$ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### PostgreSQLのインストール
```
$ brew install postgresql
```

### PostgreSQLのサービス自動起動を設定
```
$ brew services start postgresql
```

### ユーザーの作成
以下のコマンドで`PostgreSQL`にログイン後
```
$ psql -U${USER} postgres
```
以下のSQLを入力して操作用のユーザー`postgres`を作成してください。
```
postgres=# create user postgres with SUPERUSER;
```

### データベースの作成・接続
コマンドラインから以下のコマンドを実行してデータベースを作成します。
```
$ createdb memo_app -O postgres;
```

データベースの作成が完了したら先ほど作成した`postgres`ユーザーでデータベース`memo_app`に接続します。
```
$ psql -d memo_app -U postgres
```

### テーブルの作成
データベースに接続できたら
`DDL.txt`にあるテーブル作成のためのSQLを入力して`Enter`を押してください。

これでデータベース・テーブルの準備は完了です。

## ローカル環境への導入・起動
リモートリポジトリから `git clone` し、memo-appフォルダに移動した後で
```
$ bundle install
```
を実行してください。

その後
```
$ ruby app.rb -p 4567
```
でサーバーを起動してからブラウザでアクセスしてください。
