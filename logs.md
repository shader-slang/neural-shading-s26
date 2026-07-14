
2026-05-06 10:10, base line implementations of encoder+none encoder version
step02_latent:
[iter  50112] lr=5.03e-04  metric  log_l1=0.02832  rel_l1=4.10831  rmse=90.30660  valid=161648
[iter 100032] lr=1.00e-05  metric  log_l1=0.02790  rel_l1=3.67709  rmse=90.51548  valid=161648
step03_encoder:
[iter  50112] lr=5.03e-04  metric  log_l1=0.02549  rel_l1=0.46245  rmse=85.70242  valid=161648
[iter 100032] lr=1.00e-05  metric  log_l1=0.02295  rel_l1=0.32856  rmse=84.23005  valid=161648

2026-05-06 10:59, try much smaller batch sizes (64x64)
step02_latent:
[iter  50112] lr=5.03e-04  metric  log_l1=0.04342  rel_l1=56.73135  rmse=87.76795  valid=161648
[iter 100032] lr=1.00e-05  metric  log_l1=0.04265  rel_l1=56.13296  rmse=88.30966  valid=161648
step03_encoder
[iter  50112] lr=5.03e-04  metric  log_l1=0.02459  rel_l1=0.66176  rmse=87.40014  valid=161648
[iter 100032] lr=1.00e-05  metric  log_l1=0.02045  rel_l1=0.29238  rmse=90.78615  valid=161648

2026-05-06 11:52, only 2 latents
step02_latent:
[iter  50112] lr=5.03e-04  metric  log_l1=0.04427  rel_l1=51.88394  rmse=88.03286  valid=161648
[iter 100032] lr=1.00e-05  metric  log_l1=0.04366  rel_l1=54.75526  rmse=88.59582  valid=161648
step03_encoder
[iter  50048] lr=5.04e-04  metric  log_l1=0.03127  rel_l1=0.82177  rmse=93.43642  valid=161648
[iter 100032] lr=1.00e-05  metric  log_l1=0.02704  rel_l1=0.37952  rmse=91.57894  valid=161648


