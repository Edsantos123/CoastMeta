rule prepare_tiara_input:
    input:
       tiara_source = get_tiara_input
    output:
        fasta = TIARA_DIR / "input/tiara_input.fasta"
    shell:
        r"""
        mkdir -p $(dirname {output.fasta})
        rm -f {output.fasta}
        SOURCE="{input.tiara_source}"
        if [ -f "$SOURCE" ]; then
            cp "$SOURCE" {output.fasta}
        else
            BIN_DIR="$SOURCE"
            TOOL=$(basename "$BIN_DIR")
            if [ "$TOOL" = "metabat2" ]; then
                find "$BIN_DIR" -maxdepth 1 -type f \
                    -regextype posix-extended \
                    -regex '.*/bin\.[0-9]+\.fa' \
                    | sort \
                    | while read fasta; do
                        BIN=$(basename "$fasta")
                        awk -v tool="$TOOL" -v bin="$BIN" '
                            /^>/ {{
                                sub(/^>/, "")
                                print ">" tool "|" bin "|" $0
                                next
                            }}
                            {{
                                print
                            }}
                        ' "$fasta" >> {output.fasta}
                    done
            elif [ "$TOOL" = "maxbin2" ]; then
                find "$BIN_DIR" -maxdepth 1 -type f \
                    -regextype posix-extended \
                    -regex '.*/bin\.[0-9]+\.fasta' \
                    | sort \
                    | while read fasta; do
                        BIN=$(basename "$fasta")
                        awk -v tool="$TOOL" -v bin="$BIN" '
                            /^>/ {{
                                sub(/^>/, "")
                                print ">" tool "|" bin "|" $0
                                next
                            }}
                            {{
                                print
                            }}
                        ' "$fasta" >> {output.fasta}
                    done
            elif [ "$TOOL" = "dastool" ]; then
                find "$BIN_DIR" -maxdepth 1 -type f \
                    \( -name "*.fa" -o -name "*.fasta" \) \
                    | sort \
                    | while read fasta; do
                        BIN=$(basename "$fasta")
                        awk -v tool="$TOOL" -v bin="$BIN" '
                            /^>/ {{
                                sub(/^>/, "")
                                print ">" tool "|" bin "|" $0
                                next
                            }}
                            {{
                                print
                            }}
                        ' "$fasta" >> {output.fasta}
                    done
            fi
        fi
        """
