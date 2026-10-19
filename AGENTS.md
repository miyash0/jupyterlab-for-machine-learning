# AGENTS.md

## 実行環境

Python コードの実行は、必ず Docker コンテナ内の conda 環境 `ml` で行う。
ホストの Python(`python3` など)では実行しない。ホストには TensorFlow / PyTorch や GPU 用ライブラリが入っていない。

- コンテナ: `compose.yaml` のサービス `jupyter`(コンテナ名 `jupyterlab-ml`)
- 環境: `/opt/conda/envs/ml`(Python 3.13、TensorFlow / PyTorch / NumPy / Pandas / scikit-learn / Matplotlib / tqdm)
- ホストの `./work` が、コンテナ内の `/home/jovyan/work` にマウントされている

```bash
# コンテナが止まっていれば起動
docker compose up -d

# スクリプトの実行(パスはコンテナ内のもの)
docker compose exec -u jovyan -w /home/jovyan/work jupyter \
  /opt/conda/envs/ml/bin/python foo.py

# ワンライナー
docker compose exec -u jovyan jupyter \
  /opt/conda/envs/ml/bin/python -c "import torch; print(torch.cuda.is_available())"
```

## ファイル

- コードやノートブックは `./work` に置く。マウント外のファイルはコンテナから見えない。
- ファイルの読み書きはホストから直接してよい。

## パッケージの追加

- コンテナ内で `pip install` / `conda install` しない。コンテナを作り直すと消える。
- PyPI のパッケージは pip ではなく uv で入れる。uv はベース環境(`/opt/conda/bin/uv`)にあり、`--python` で入れる先の環境を指定する。
- conda で入るものは `environment.yml` の `dependencies` に、pip でしか入らないものは `requirements.txt` に書く(uv でインストールされる)。
- JupyterLab の拡張機能はサーバーが動くベース環境に入れるので、Dockerfile に `uv pip install --python /opt/conda/bin/python ...` で書く。
- 書いたら次のコマンドでイメージを作り直す。

```bash
docker compose up -d --build
```
