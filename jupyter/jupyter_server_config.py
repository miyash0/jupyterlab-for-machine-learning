# JupyterLab のサーバー設定。イメージの /usr/local/etc/jupyter に置かれる
c = get_config()  # noqa: F821

# ファイルブラウザのルートを ./work にする。
# ホームはマウント外なので、そこに作ったノートブックはコンテナを作り直すと消える
c.ServerApp.root_dir = "/home/jovyan/work"

# ノートブックを移動したら、カーネル再起動で新しい場所が cwd になるようにする
c.AsyncMappingKernelManager.kernel_manager_class = (
    "follow_notebook_kernel.FollowNotebookKernelManager"
)
