clean:
	@rm .[a-z]* -rf
	@ls | grep -v top.sv | grep -v Makefile | xargs rm -rf

comp:
	vlogan -sverilog -full64 -debug_acc+all -q -ntb_opts uvm \
				+define+UVM_NO_DEPRECATED \
				+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
				+incdir+${UVM_HOME} \
				+incdir+${UVM_HOME}/vcs \
				+incdir+${UVM_HOME}/verdi \
				+incdir+../../yuu_common/src/sv \
				+incdir+../../yuu_amba/src/sv \
				+incdir+../../yuu_amba/include \
				${UVM_HOME}/uvm_pkg.sv \
				${UVM_HOME}/vcs/uvm_custom_install_vcs_recorder.sv \
				${UVM_HOME}/verdi/uvm_custom_install_verdi_recorder.sv \
				../../yuu_common/include/yuu_common_pkg.sv \
				../../yuu_amba/include/yuu_amba_pkg.sv
	vlogan -sverilog -full64 -debug_acc+all -q -ntb_opts uvm \
				 +incdir+../include \
				 +incdir+../src/sv/yuu_apb_common \
				 +incdir+../src/sv/yuu_apb_master \
				 +incdir+../src/sv/yuu_apb_slave \
				 +incdir+../src/sv/yuu_apb_env \
				 ../include/yuu_apb_pkg.sv;
	vlogan -sverilog -full64 -debug_acc+all -q -ntb_opts uvm \
				 +incdir+../include \
				 +incdir+../src/sv/yuu_apb_common \
				 +incdir+../src/sv/yuu_apb_master \
				 +incdir+../src/sv/yuu_apb_slave \
				 +incdir+../src/sv/yuu_apb_env \
				 top.sv
	vcs -sverilog -full64 -debug_acc+all -q -ntb_opts uvm -timescale=1ns/1ns -top top
