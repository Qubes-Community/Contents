# qvm-* commands bash auto completion

# Copy this file to /etc/bash_completion.d/qvm.sh

# credit: https://www.mail-archive.com/qubes-users@googlegroups.com/msg20088.html

_qvm()
{
	local cur vms
	local state=${1}
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	case ${state} in
		running|halted|paused)
			vms=$(qvm-ls --raw-data | grep -i "${state}" | cut -f1 -d"|")
			;;
		"")
			vms=$(qvm-ls --raw-list)
			;;
		*)	vms=""
	esac
	COMPREPLY=( $(compgen -W "${vms}" ${cur}) )
	return 0
}

_qvmall()     { _qvm ""; }
_qvmrunning() { _qvm "running"; }
_qvmhalted()  { _qvm "halted"; }
_qvmpaused()  { _qvm "paused"; }

complete -F _qvmall qvm-appmenus
complete -F _qvmall qvm-backup
complete -F _qvmall qvm-backup-restore
complete -F _qvmall qvm-check
complete -F _qvmall qvm-clone
complete -F _qvmall qvm-copy-to-vm
complete -F _qvmall qvm-features
complete -F _qvmall qvm-firewall
complete -F _qvmall qvm-move-to-vm
complete -F _qvmall qvm-prefs
complete -F _qvmall qvm-remove
complete -F _qvmall qvm-run
complete -F _qvmall qvm-service
complete -F _qvmall qvm-start-gui
complete -F _qvmall qvm-tags
complete -F _qvmall qvm-usb
complete -F _qvmhalted qvm-start
complete -F _qvmpaused qvm-unpause
complete -F _qvmrunning qvm-kill
complete -F _qvmrunning qvm-pause
complete -F _qvmrunning qvm-shutdown
