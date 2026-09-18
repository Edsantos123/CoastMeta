from pathlib import Path
import gzip
import shutil
import os

############################################
# STAGING + NORMALIZAÇÃO + COMPRESSÃO
############################################

rule stage_reads:
    input:
        r1 = config["r1"],
        r2 = config["r2"]
    output:
        r1 = RAW_DIR / "read_1.fastq.gz",
        r2 = RAW_DIR / "read_2.fastq.gz"
    run:
        os.makedirs(RAW_DIR, exist_ok=True)

        def to_gz(src, dst):
            src = str(src)
            dst = str(dst)

            if src.endswith(".gz"):
                shutil.copyfile(src, dst)
            else:
                with open(src, "rb") as f_in, gzip.open(dst, "wb") as f_out:
                    shutil.copyfileobj(f_in, f_out)

        to_gz(input.r1, output.r1)
        to_gz(input.r2, output.r2)

        print("Staging concluído:")
        print(" ->", output.r1)
        print(" ->", output.r2)
