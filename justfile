alias up := update
alias pup := post-update

update:
	./sources.sh unattended
	./build.sh boot
	git push
	kubectl drain rpi4 --ignore-daemonsets --delete-emptydir-data
	sudo reboot

post-update:
	kubectl uncordon rpi4
	nix-collect-garbage -d
	sudo nix-collect-garbage -d
	sudo /run/current-system/bin/switch-to-configuration boot

kube-vm:
	#!/usr/bin/env bash
	echo "Cleaning up old potentially stale disk. If unwanted, use kube-vm-resume."
	rm -f kube-qemu.qcow2
	just kube-vm-resume

kube-vm-resume:
	#!/usr/bin/env bash
	vm_path="$(./build.sh --print-out-path --attr config.system.build.vm --hostname kube-qemu)"
	QEMU_NET_OPTS=hostfwd=tcp::2222-:22 "$vm_path"/bin/run-kube-qemu-vm -display none &
	qemu_pid=$!
	echo "Waiting 30 seconds for vm to become ready before starting to attempt connection..."
	sleep 30
	until ssh -p 2222 -o "UserKnownHostsFile=/dev/null" -o "ConnectTimeout=5" -o "StrictHostKeyChecking=no" rj@localhost ; do
		sleep 1
	done
	echo "ssh session ended, tearing down VM"
	kill -9 $qemu_pid
