##################################################
#
# PERIDOT-AIR jic file generator
#
#	2020/04/21	s.osafune@j7system.jp
#	2021/10/13	update EPCCQ16A -> EPCQ16
#
##################################################

set module [lindex $quartus(args) 0]

if [string match "quartus_asm" $module] {
    post_message "Running after assembler"

	# get project name path

	set rev_name [lindex $quartus(args) 2]
	set prj_path "output_files/${rev_name}"

#	set crom_devide "EPCS4"
	set crom_devide "EPCQ16"
#	set crom_devide "EPCQ16A"
	set fpga_device "EP4CE6"

	# make cof file

	set cof_xml "<?xml version=\"1.0\" encoding=\"US-ASCII\" standalone=\"yes\"?>
<cof>
\t<eprom_name>${crom_devide}</eprom_name>
\t<flash_loader_device>${fpga_device}</flash_loader_device>
\t<output_filename>${prj_path}.jic</output_filename>
\t<n_pages>1</n_pages>
\t<width>1</width>
\t<mode>7</mode>
\t<sof_data>
\t\t<user_name>Page_0</user_name>
\t\t<page_flags>1</page_flags>
\t\t<bit0>
\t\t\t<sof_filename>${prj_path}.sof<compress_bitstream>1</compress_bitstream></sof_filename>
\t\t</bit0>
\t</sof_data>
\t<version>10</version>
\t<create_cvp_file>0</create_cvp_file>
\t<create_hps_iocsr>0</create_hps_iocsr>
\t<auto_create_rpd>0</auto_create_rpd>
\t<rpd_little_endian>1</rpd_little_endian>
\t<options>
\t\t<map_file>1</map_file>
\t</options>
\t<advanced_options>
\t\t<ignore_epcs_id_check>2</ignore_epcs_id_check>
\t\t<ignore_condone_check>2</ignore_condone_check>
\t\t<plc_adjustment>0</plc_adjustment>
\t\t<post_chain_bitstream_pad_bytes>-1</post_chain_bitstream_pad_bytes>
\t\t<post_device_bitstream_pad_bytes>-1</post_device_bitstream_pad_bytes>
\t\t<bitslice_pre_padding>1</bitslice_pre_padding>
\t</advanced_options>
</cof>"

	set cof_path "${prj_path}_auto.cof"

	set cof_file_id [open $cof_path w]
	puts $cof_file_id $cof_xml
	close $cof_file_id


	# convert programming file

	set cpf_cmd "quartus_cpf -c ${cof_path}"

	if { [catch {open "|$cpf_cmd"} errcode] } {
		return -code error $errcode
	}
}
