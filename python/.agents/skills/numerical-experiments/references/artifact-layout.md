# Artifact Layout

## 目标

让实验结果目录可定位、可理解、可继续使用，并为后续绘图保留稳定入口。

## 默认布局

默认将一次运行组织到：

```text
artifacts/
  experiments/
    <experiment_name>/
      <run_id>/
        run_manifest.json
        summary.json
        results/
        plots/
        plot_data/
```

若项目已有更合适的 artifact 根目录或运行目录约定，优先贴合项目现状，不必机械迁移。

## 核心文件

- MUST: `run_manifest.json` 用于定位本次 run 的基本信息、配置来源或配置摘要、case 组织方式、主要输出位置、失败记录入口和 case 状态。
- MUST: `summary.json` 用于记录本次 run 的总体状态、成功/失败计数、关键结果摘要和剩余工作量摘要。
- SHOULD: case 级结果与状态记录保持可发现，不要求固定成某一种文件拆分方式。
- SHOULD: 断点续跑时优先依据 manifest 中的 case 状态判断哪些 case 需要跳过、继续或重试，而不是只靠目录里有没有文件来猜测。
- SHOULD: 只有在关键输出完整写出后，才将 case 记为完成，避免中断后把半成品误判为可跳过结果。

## 推荐子目录

- SHOULD: 将主要结果文件集中放在语义清晰的位置，避免 run 根目录过度堆叠。
- SHOULD: 当实验已经产出图像时，使用 `plots/` 保存图像输出。
- SHOULD: 当需要为后续绘图保留输入数据时，使用 `plot_data/` 保存绘图直接消费的数据。
- SHOULD: 原始结果、派生结果和图像输入尽量分开放置，避免后续任务混淆来源。

## 结果格式建议

参考文档只给推荐，不给硬规则：

- 表格数据常见可用 `parquet` 或 `csv`
- 数值数组常见可用 `npy` / `npz`
- 结构化元数据常见可用 `json`

优先选择高效、稳定、方便后续处理的格式，不要因为单一格式偏好而牺牲可读性或下游可用性。
