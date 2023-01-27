
SOURCE_DIR=SSL_Certs

cd $SOURCE_DIR
./1_gen_certs_gmsec.sh
./2_gen_certs_generic.sh
./3_move_certs.sh

