NicoAnime
====

NicoAnimeはニコニコチャンネルの無料配信動画をアーカイブすることのできるウェブアプリです。

Requirements
----

- Ruby（Version 1.9 もしくはそれ以降）
    - Ruby/MySQL
    - Bundler
- PHP（Version 5.3 もしくはそれ以降）
    - DOM
    - PDO (MySQL)
- Apache
    - mod_rewrite
- MySQL

Install
----

いくつかのステップが必要です。

（将来的に実行環境をDockerfileとして提供したいと思っています。）

### rtmpdumpの導入

rtmpeプロトコルの動画をダウンロードするため，下記のようにして[rtmpdump](http://rtmpdump.mplayerhq.hu/)を導入します。
rtmpdumpの実行ファイルはパスの通っている場所に配置する必要があります。

~~~~
$ cd ~/tmp
$ git clone git://git.ffmpeg.org/rtmpdump
$ cd ~/tmp/rtmpdump
$ ./configure
$ make
$ sudo make install
~~~~

### 必要なファイル郡の設置

~~~~
$ git clone https://github.com/tondol/NicoAnime.git ~/www/nicoanime
$ cd ~/www/nicoanime
$ git submodule update --init
~~~~

### インストールスクリプトの実行

~~~~
$ ./install.sh
~~~

足りないものがある場合はインストールする旨のメッセージが出力され，終了します。
必要なコマンド等が揃っていれば，設定入力のプロンプトが表示されるので，各項目を入力してください。
無事完了すれば，必要なgemのインストールやテーブルの作成等が自動で行われます。

### apache/nginxの設定

&lt;設置したパス&gt;/public をドキュメントルートとして設定します。
Pretty URLs対応のため，適宜URLのリダイレクト設定を行う必要があります。
`.htaccess.example`がapache用のサンプルとして用意されています。

~~~~
$ cd ~/www/nicoanime/public
$ cp .htaccess.example .htaccess
$ vim .htaccess
~~~~

**Basic認証などの方法によりアクセス制限の設定を追加すること** を強くお薦めします。

### crontabの設定

ruby/crawler.rb と ruby/downloader.rb を定期実行するように設定します。

~~~~
$ crontab -e
~~~~

~~~~
# 記述例

SHELL=/bin/bash
HOME=/home/foo
MAILTO=""

# nicoanime
NICOANIME_DIR=/home/foo/www/ruby
00 * * * * ruby $NICOANIME_DIR/crawler.rb >> $NICOANIME_DIR/nicoanime.log 2>> $NICOANIME_DIR/error.log
30 * * * * ruby $NICOANIME_DIR/downloader.rb >> $NICOANIME_DIR/nicoanime.log 2>> $NICOANIME_DIR/error.log
~~~~

HOW TO USE
----

&lt;設置先URL&gt;/help/ をブラウザで閲覧してください。
