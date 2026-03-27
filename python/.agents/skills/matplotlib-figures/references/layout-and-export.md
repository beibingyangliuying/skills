# Layout And Export

## 目标

让图形在保存与展示时保持布局稳定，并使用与场景匹配的导出参数。

## 布局处理

- SHOULD: 在保存或显示图像前，优先处理布局问题。
- SHOULD: 通常可使用 `plt.tight_layout()`。
- MUST: 若代码已使用 `constrained_layout=True` 或已有明确的手动布局控制，不要机械重复调用 `tight_layout()`。
- MUST: 不要为了套用布局规则而破坏已有图形效果。

## 导出规则

- SHOULD: 使用 `plt.savefig()` 时优先显式设置 `bbox_inches="tight"`。
- SHOULD: 图像导出格式优先遵循仓库既有产出规范。
- SHOULD: 若无明确要求，科研绘图默认优先考虑矢量格式，如 `svg` 或 `pdf`。
- MAY: 在项目明确要求时使用 `format="svg"`、`dpi=600` 等导出参数。
- MUST: 若任务或现有脚本已明确指定导出格式，不擅自改成其他格式。
