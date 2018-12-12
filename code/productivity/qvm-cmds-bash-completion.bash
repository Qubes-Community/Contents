# qvm-* commands bash auto completion

# Copy this file to /etc/bash_completion.d/qvm.bash

# idea from https://www.mail-archive.com/qubes-users@googlegroups.com/msg20088.html
#  credit to haaber for the original PoC !

# @taradiddles - apr 2018 - GPL



# COMPLETION FUNCTIONS
# ====================

# Output the relative position of COMP_CWORD with option words ignored
# Note: This logic is flawed when using option arguments (eg. -s blah).
#       Unfortunately there is no way to solve this except parsing every
#       known option for a given qvm-* command
_get-cword() {
	local index=0
	local i
	for ((i=1; i<=COMP_CWORD; i++)); do 
		[[ ${COMP_WORDS[i]} == -* ]] && continue
		let index++
	done
	echo ${index}
}

# Output the relative position of COMP_CWORD with option words ignored
# Note: This logic is flawed when using option arguments (eg. -s blah).
#       Unfortunately there is no way to solve this except parsing every
#       known option for a given qvm-* command
_get-first-word() {
	local i
	for ((i=1; i<=COMP_CWORD; i++)); do 
		[[ ${COMP_WORDS[i]} == -* ]] && continue
		echo ${COMP_WORDS[i]}
		return 0
	done
	echo ""
}

_complete-vms() {
	local vms
	local state="${1}"
	local cur="${COMP_WORDS[COMP_CWORD]}"
	case "${state}" in
		runtrans)
			vms=$(qvm-ls --raw-data | grep -i "|\(running\|transient\)|" | cut -f1 -d"|")
			;;
		running|halted|paused)
			vms=$(qvm-ls --raw-data | grep -i "|${state}|" | cut -f1 -d"|")
			;;
		"")
			vms=$(qvm-ls --raw-list)
			;;
	esac
	COMPREPLY=( $(compgen -W "${vms}" -- "${cur}") )
	return 0
}

_complete-filenames() {
	local cur="${COMP_WORDS[COMP_CWORD]}"
	COMPREPLY=( $(compgen -f -- "$cur") )
	return 0
}

_complete-vmprops() {
	local vm="${1}"
	local property="${2}"
	local props
	local cur="${COMP_WORDS[COMP_CWORD]}"
	if qvm-check "${vm}" > /dev/null 2>&1; then
		case "${property}" in
			prefs)
				props=$(qvm-prefs "${vm}" | cut -f1 -d " ")
				;;
			features)
				props=$(qvm-features "${vm}" | cut -f1 -d " ")
				;;
			tags)
				props=$(qvm-tags "${vm}" | cut -f1 -d " ")
				;;
		esac
	fi
	COMPREPLY=( $(compgen -W "${props}" -- "${cur}") )
}



# WRAPPERS and COMPLETE functions
# ===============================

#----- args: vm(all) -----
_qvm-vms-all-all() {
	_complete-vms ""
}
complete -F _qvm-vms-all-all qvm-backup
complete -F _qvm-vms-all-all qvm-ls


#----- arg1: vm(all) -----
_qvm-vms-all() {
	[ $(_get-cword ${COMP_CWORD}) = 1 ] && _complete-vms ""
}
complete -F _qvm-vms-all qvm-check
complete -F _qvm-vms-all qvm-clone
complete -F _qvm-vms-all qvm-firewall
complete -F _qvm-vms-all qvm-remove
complete -F _qvm-vms-all qvm-run
complete -F _qvm-vms-all qvm-service
complete -F _qvm-vms-all qvm-start-gui
complete -F _qvm-vms-all qvm-usb


#----- arg1: vm(halted) -----
_qvm-vms-halted() {
	[ $(_get-cword ${COMP_CWORD}) = 1 ] && _complete-vms "halted"
}
complete -F _qvm-vms-halted qvm-start


#----- arg1: vm(paused) -----
_qvm-vms-paused() {
	[ $(_get-cword ${COMP_CWORD}) = 1 ] && _complete-vms "paused"
}
complete -F _qvm-vms-paused qvm-unpause


#----- arg1: vm(running) -----
_qvm-vms-running() {
	[ $(_get-cword ${COMP_CWORD}) = 1 ] && _complete-vms "running"
}
complete -F _qvm-vms-running qvm-pause
complete -F _qvm-vms-running qvm-shutdown


#----- arg1: vm(running|transient) -----
_qvm-vms-runtrans() {
	[ $(_get-cword ${COMP_CWORD}) = 1 ] && _complete-vms "runtrans"
}
complete -F _qvm-vms-runtrans qvm-kill


#----- arg1: vm(all) ; arg(>=2): filenames -----
_qvm-vms-all-filenames() {
	if [ "$(_get-cword ${COMP_CWORD})" -eq 1 ]; then
		 _complete-vms ""
	else
		_complete-filenames
	fi
}
complete -F _qvm-vms-all-filenames qvm-copy-to-vm
complete -F _qvm-vms-all-filenames qvm-move-to-vm


#----- arg1: vm(all) ; arg2: vm preferences -----
_qvm-vms-all-vmprefs() {
	case "$(_get-cword ${COMP_CWORD})" in
		1) _complete-vms "" ;;
		2) _complete-vmprops "$(_get-first-word)" "prefs";;
	esac
}
complete -F _qvm-vms-all-vmprefs qvm-prefs


#----- arg1: vm(all) ; arg2: vm features -----
_qvm-vms-all-vmfeatures() {
	case "$(_get-cword ${COMP_CWORD})" in
		1) _complete-vms "" ;;
		2) _complete-vmprops "$(_get-first-word)" "features";;
	esac
}
complete -F _qvm-vms-all-vmfeatures qvm-features


#----- arg1: vm(all) ; arg2: vm tags -----
_qvm-vms-all-vmtags() {
	case "$(_get-cword ${COMP_CWORD})" in
		1) _complete-vms "" ;;
		2) _complete-vmprops "$(_get-first-word)" "tags";;
	esac
}
complete -F _qvm-vms-all-vmtags qvm-tags

