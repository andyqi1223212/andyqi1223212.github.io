"""本地 mkdocs serve：禁止浏览器缓存页面（仅 development server）。"""

import logging

log = logging.getLogger("mkdocs.plugins.hooks")


def on_serve(server, builder, **kwargs):
    class NoCacheMiddleware:
        def __init__(self, app):
            self._app = app

        def __call__(self, environ, start_response):
            def inject_no_cache(status, headers, exc_info=None):
                filtered = [
                    (k, v)
                    for k, v in headers
                    if k.lower() not in ("cache-control", "pragma", "expires")
                ]
                filtered.extend(
                    [
                        ("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0"),
                        ("Pragma", "no-cache"),
                        ("Expires", "0"),
                    ]
                )
                return start_response(status, filtered, exc_info)

            return self._app(environ, inject_no_cache)

    server.set_app(NoCacheMiddleware(server.application))
    log.warning("本地预览已启用 no-cache 响应头（hooks.on_serve）")
    return server


on_serve.mkdocs_priority = -1000
