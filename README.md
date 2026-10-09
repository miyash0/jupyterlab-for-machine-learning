# JupyterLab for Machine Learning

Google Colab に近いノートブック環境を、ローカルの Docker で動かす構成です。
TensorFlow / Keras、GPU(NVIDIA)、Tailscale 経由のアクセスを前提にしています。

## 構成

- イメージ: `quay.io/jupyter/tensorflow-notebook:cuda12-latest`(公式、conda ベース)
  - conda 環境は標準で入っているため、別の仮想環境は作りません。
  - 追加パッケージは `requirements.txt` に書いてビルドします。
- `./work` をコンテナ内の `/home/jovyan/work` にマウントします。
- ポートはホストの `127.0.0.1:8888` のみ公開し、外部へは `tailscale serve` で出します。

## 前提

- Linux ホスト、NVIDIA ドライバ、NVIDIA Container Toolkit
- Docker / Docker Compose v2
- Tailscale(ホストにインストール済み)

## 使い方

```bash
cp .env.example .env     # JUPYTER_TOKEN を変更し、NB_UID/NB_GID を id -u / id -g に合わせる
docker compose up -d --build
```

GPU の確認(JupyterLab のノートブックで):

```python
import tensorflow as tf
print(tf.config.list_physical_devices("GPU"))
```

## Tailscale で公開(tailnet 内のみ)

```bash
sudo tailscale serve --bg 8888
tailscale serve status    # 公開 URL を確認
```

クライアントから `https://<ホスト名>.<tailnet>.ts.net/` を開き、トークンを入力します。
止める場合は `sudo tailscale serve reset` を実行します。

### `/jupyter` のようなパス付き公開について

`tailscale serve --set-path` は、転送時にパスのプレフィックスを外します。
そのため Jupyter 側の `base_url` と食い違い、ページが正しく表示されません。
このリポジトリではルート(`/`)公開を前提にしています。
パスが必要な場合は、別ポートで公開する方法(`tailscale serve --bg --https=8443 8888`)が簡単です。

## 停止・更新

```bash
docker compose down
docker compose build --pull && docker compose up -d
```
