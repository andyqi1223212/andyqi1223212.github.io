/* 仅本地预览：从往返缓存恢复时强制整页重载 */
(function () {
  var host = window.location.hostname;
  if (host !== "127.0.0.1" && host !== "localhost") return;
  window.addEventListener("pageshow", function (event) {
    if (event.persisted) window.location.reload();
  });
})();
