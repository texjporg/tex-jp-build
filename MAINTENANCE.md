# How to maintain this repository

## メンテナンスの基本方針

[TeX Live and Subversion](http://www.tug.org/texlive/svn/)のsubversionリポジトリのサブセットをgit svnで作成、追従しこちらの[gitHub](https://github.com/texjporg/tex-jp-build.git)の`master`と同期させる。

## リポジトリの構成

ローカルに作成する作業用リポジトリのブランチは以下のように構成する。

1. texlive-gitsvn : TeX Live svn側と直接 `git svn` で追従する。ローカルで使用し[gitHub](https://github.com/texjporg/tex-jp-build.git)には公開しない。
2. texlive-trunk  : `texlive-gitsvn` と内容をcherry pickで完全に同期させる。[gitHub](https://github.com/texjporg/tex-jp-build.git)にも公開する。
3. master         : texjporg側のmasterブランチ。`texlive-trunk`と同期させつつ、`README.md`など独自の内容を含む。[gitHub](https://github.com/texjporg/tex-jp-build.git)に公開する。
4. その他          : 開発用


`texlive-gitsvn` と `texlive-trunk` は内容が完全に一致するがコミットハッシュが異なっている状態を維持する。両者はコミットツリー上常に並列であり交差することはない。
`texlive-gitsvn` と `texlive-trunk` を別のブランチで運用している理由は以下。

* `git svn`で生成される`texlive-gitsvn`におけるコミットハッシュが `texlive-trunk` と合わなくても問題にならない。
* `git svn`で同期する構成物を変更したくなったときに対応しやすい。

## リポジトリの運用

### ローカルの作業用リポジトリの作成手順

最初に一度実行する必要がある。
また、`git svn`で同期する構成物を変更する場合、`git svn clone`の`--ignore-paths`を更新してやり直す必要がある。

#### ブランチ`texlive-gitsvn`の作成

```
mkdir workXXX
cd workXXX
cp -p hoge/usermap_texlive_svn.txt .
git svn clone svn://tug.org/texlive/trunk/Build -r 61101:HEAD --ignore-paths='^((?!source).*|source/(extra|libs/(freetype|gd|graphite|harfbuzz|lua|poppler|potrace|teckit|xpdf|zziplib)|utils/(a[^c]|[bd-z])|texk/(afm|bib|chk|cjk|det|dtl|dvil|dvipn|dvipo|dvis|gre|gsf|lcd|makei|mus|ps2|psu|tex4|texlive/linked_scripts(?!/(ChangeLog|Makefile.in)).*|ttf|xdv|web2c/(xetexdir|mfluadir|mfluajitdir|alephdir|pdftexdir|luatexdir(?!/luafontloader/ff-config.in).*))))' --authors-file=usermap_texlive_svn.txt
cd Build/
git branch -m master texlive-gitsvn
```

#### ブランチ`texlive-trunk`, `master`の作成

```
git remote add origin git@github.com:texjporg/tex-jp-build.git
git remote -v
git checkout -b master origin/master
git checkout -b texlive-trunk origin/texlive-trunk
git worktree add ../texlive-gitsvn texlive-gitsvn
```

### リポジトリの同期

定期的にTeX Live svnと同期するための作業。
現在は一週間に一回程度実施している。

```
cd workXXX/texlive-gitsvn/
git svn fetch
```

`usermap_texlive_svn.txt` に記載されていない新しいコミッターの方が入った場合、ここでwaringが出るので `usermap_texlive_svn.txt` を編集してから上記をやり直す。
編集した場合は`master`ブランチの中にある `workXXX/Build/usermap_texlive_svn.txt` も更新すべし。

```
git log remotes/git-svn
git log remotes/git-svn --oneline
```

これを見て前回の最終と今回の最終のコミットハッシュをメモしておく。
例えば `ffb1af1b4..d39202e05` だったとする。

```
cd workXXX/Build/
git checkout texlive-trunk
git cherry-pick ffb1af1b4..d39202e05 --allow-empty
git diff texlive-gitsvn
```

ブランチ`texlive-gitsvn` と `texlive-trunk` は内容が完全に同じでコミットハッシュだけが異なる状態になっているはず。

```
git checkout master
git remote -v
git fetch
git merge origin/master
git merge texlive-trunk --no-commit
```

コンフリクトが発生した場合はこの段階で適宜対処する。

```
git commit
```

ここでコミットログに TeX Live svn の最終のリビジョンを ` r61xxx` のように追記する。必須ではないと思うが履歴を見るときに役立つことを期待。

```
git diff texlive-gitsvn
```

texjporg で追加したファイル以外は完全に同内容になっているはず。

```
git push origin master
git push origin texlive-trunk
```

## 註

ここで記載した手順は必須でも絶対でもなく、現状こうしているというやり方をメモしたものです。
もっといいやり方や提案等あれば教えてください。

以上。
