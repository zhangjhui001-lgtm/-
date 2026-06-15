# 策划工具网页

这是一个静态网站项目，可直接部署到 GitHub Pages。

## 发布方式

1. 把整个目录推到 GitHub 仓库的 `main` 分支。
2. 到仓库 `Settings -> Pages -> Build and deployment`。
3. 选择 `GitHub Actions` 作为发布来源。
4. 推送后，`Deploy to GitHub Pages` 工作流会自动发布站点。

## 本项目特性

- `index.html` 为站点入口
- `tools.json` 为页面数据源
- `assets/` 存放本地资源
- `.nojekyll` 用于避免 GitHub Pages 的 Jekyll 处理影响静态资源

## 访问注意

页面里使用了外部资源：

- `https://unpkg.com/lucide@latest`
- 图标 favicon 的外链地址

如果希望站点完全离线可用，可以后续把这些资源改成本地文件。
