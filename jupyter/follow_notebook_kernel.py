"""ノートブックの移動・改名に、カーネルの作業ディレクトリを追従させる。

カーネルの cwd は起動時のノートブックの場所で決まり、移動しても変わらない。
jupyter_server は移動時に update_env で新しいパス(JPY_SESSION_NAME)を渡してくるので、
そこから cwd も更新し、次のカーネル再起動で新しい場所になるようにする。
"""

import os

from jupyter_server.services.kernels.kernelmanager import ServerKernelManager


class FollowNotebookKernelManager(ServerKernelManager):
    def update_env(self, *, env):
        super().update_env(env=env)
        path = env.get("JPY_SESSION_NAME")
        if isinstance(self._launch_args, dict) and path:
            cwd = os.path.dirname(path)
            if os.path.isdir(cwd):
                self._launch_args["cwd"] = cwd
