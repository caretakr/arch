label: gpt
device: /dev/{{ storage_device }}
unit: sectors
first-lba: 2048
sector-size: 512

/dev/{{ boot_partition }}: start={{ boot_start }}, size={{ boot_size }}, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
/dev/{{ swap_partition }}: start={{ swap_start }}, size={{ swap_size }}, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
/dev/{{ data_partition }}: start={{ data_start }}, size=, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4
