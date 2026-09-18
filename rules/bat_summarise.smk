################################################
# BAT - SUMMARISE
################################################

rule bat_summarise:
    input:
        named = CAT_BAT_DIR / "bat.bin2classification.named.txt"
    output:
        summary = CAT_BAT_DIR / "bat.summary.txt"
    log:
        CAT_BAT_DIR / "logs/bat_summarise.log"
    shell:
        r"""
        mkdir -p $(dirname {output.summary})
        mkdir -p $(dirname {log})

        if ! docker run --rm \
            -u $(id -u):$(id -g) \
            -v $(pwd):/data \
            cat_image \
            summarise \
            -i /data/{input.named} \
            -o /data/{output.summary} \
            > {log} 2>&1
        then
            exit 1
        fi
        """