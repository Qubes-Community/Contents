
# CentOS Template

If you would like to use a stable, predictable, manageable and reproducible distribution in your AppVMs, you can install the CentOS template, provided by Qubes in ready to use binary package. For the minimal and Xfce versions, please see the [Minimal TemplateVMs] and [Xfce TemplateVMs] pages.


## Installation

The standard CentOS TemplateVM can be installed with the following command in dom0, where `X` is the desired version number:

    [user@dom0 ~]$ sudo qubes-dom0-update --enablerepo=qubes-templates-community qubes-template-centos-X

To switch, reinstall and uninstall a CentOS TemplateVM that is already installed in your system, see *How to [switch], [reinstall] and [uninstall]*.

#### After Installing

After a fresh install, we recommend to [Update the TemplateVM](https://www.qubes-os.org/doc/software-update-vm/).

## CentOS 8 End of Life

With the end of 2021, CentOS ended its life in its stable form and started functioning as CentOS Stream, a development branch for Red Hat® Enterprise Linux®. As a result, it stopped receiving proven, stable updates and its use, especially in production environments, became risky. This is a very serious problem for many companies and individuals around the world. So there was an urgent need to find a new source of updates for CentOS in order to keep it in the infrastructure. A complete solution to this problem is support switching, that is, pointing to a new repository from which CentOS will be downloading stable updates. Such a solution is offered by various Enterprise Linux vendors such as AlmaLinux, EuroLinux or Rocky Linux. It is worth mentioning that both CentOS and RHEL and AlmaLinux/EuroLinux/Rocky Linux are systems built on the same source code, so they provide the same functionality. They differ mainly in branding.

It's up to the user to decide, which Enterprise Linux 8 they want to migrate to. There are some differences mainly in the time it takes to release updates, errata, major and minor releases, etc. but it's up to the user to do their own research for that in order to provide an unbiased opinion.

### How to migrate your CentOS 8 template

We'll use vendors' migration scripts for migrating our CentOS 8 template.

The scripts will perform various operations that may require connecting the template to the Internet.

The scripts are located in

- https://github.com/AlmaLinux/almalinux-deploy - for AlmaLinux
- https://github.com/EuroLinux/eurolinux-migration-scripts - for EuroLinux
- https://github.com/rocky-linux/rocky-tools - for Rocky Linux

Please read their manuals for a successful operation.

Please update your CentOS 8 template to the latest officially released CentOS 8.5 before running the scripts.

#### How to update to CentOS 8.5

Edit your CentOS 8 repositories so they point to release 8.5 in CentOS Vault. You can use the following commands:

```
sudo sed -i -e '/mirrorlist=http:\/\/mirrorlist.centos.org\/?release=$releasever&arch=$basearch&repo=/ s/^#*/#/' -e '/baseurl=http:\/\/mirror.centos.org\/$contentdir\/$releasever\// s/^#*/#/' -e '/^\[BaseOS\]/a baseurl=https://mirror.rackspace.com/centos-vault/8.5.2111/BaseOS/$basearch/os' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -i -e '/mirrorlist=http:\/\/mirrorlist.centos.org\/?release=$releasever&arch=$basearch&repo=/ s/^#*/#/' -e '/baseurl=http:\/\/mirror.centos.org\/$contentdir\/$releasever\// s/^#*/#/' -e '/^\[AppStream\]/a baseurl=https://mirror.rackspace.com/centos-vault/8.5.2111/AppStream/$basearch/os' /etc/yum.repos.d/CentOS-AppStream.repo
sudo sed -i -e '/mirrorlist=http:\/\/mirrorlist.centos.org\/?release=$releasever&arch=$basearch&repo=/ s/^#*/#/' -e '/baseurl=http:\/\/mirror.centos.org\/$contentdir\/$releasever\// s/^#*/#/' -e '/^\[cr\]/a baseurl=https://mirror.rackspace.com/centos-vault/8.5.2111/ContinuousRelease/$basearch/os' /etc/yum.repos.d/CentOS-CR.repo
sudo sed -i -e '/mirrorlist=http:\/\/mirrorlist.centos.org\/?release=$releasever&arch=$basearch&repo=/ s/^#*/#/' -e '/baseurl=http:\/\/mirror.centos.org\/$contentdir\/$releasever\// s/^#*/#/' -e '/^\[Devel\]/a baseurl=https://mirror.rackspace.com/centos-vault/8.5.2111/Devel/$basearch/os' /etc/yum.repos.d/CentOS-Devel.repo
sudo sed -i -e '/mirrorlist=http:\/\/mirrorlist.centos.org\/?release=$releasever&arch=$basearch&repo=/ s/^#*/#/' -e '/baseurl=http:\/\/mirror.centos.org\/$contentdir\/$releasever\// s/^#*/#/' -e '/^\[extras\]/a baseurl=https://mirror.rackspace.com/centos-vault/8.5.2111/extras/$basearch/os' /etc/yum.repos.d/CentOS-Extras.repo
sudo sed -i -e '/mirrorlist=http:\/\/mirrorlist.centos.org\/?release=$releasever&arch=$basearch&repo=/ s/^#*/#/' -e '/baseurl=http:\/\/mirror.centos.org\/$contentdir\/$releasever\// s/^#*/#/' -e '/^\[fasttrack\]/a baseurl=https://mirror.rackspace.com/centos-vault/8.5.2111/fasttrack/$basearch/os' /etc/yum.repos.d/CentOS-fasttrack.repo
sudo sed -i -e '/mirrorlist=http:\/\/mirrorlist.centos.org\/?release=$releasever&arch=$basearch&repo=/ s/^#*/#/' -e '/baseurl=http:\/\/mirror.centos.org\/$contentdir\/$releasever\// s/^#*/#/' -e '/^\[HighAvailability\]/a baseurl=https://mirror.rackspace.com/centos-vault/8.5.2111/HighAvailability/$basearch/os' /etc/yum.repos.d/CentOS-HA.repo
sudo sed -i -e '/mirrorlist=http:\/\/mirrorlist.centos.org\/?release=$releasever&arch=$basearch&repo=/ s/^#*/#/' -e '/baseurl=http:\/\/mirror.centos.org\/$contentdir\/$releasever\// s/^#*/#/' -e '/^\[centosplus\]/a baseurl=https://mirror.rackspace.com/centos-vault/8.5.2111/centosplus/$basearch/os' /etc/yum.repos.d/CentOS-centosplus.repo
sudo sed -i -e '/mirrorlist=http:\/\/mirrorlist.centos.org\/?release=$releasever&arch=$basearch&repo=/ s/^#*/#/' -e '/baseurl=http:\/\/mirror.centos.org\/$contentdir\/$releasever\// s/^#*/#/' -e '/^\[PowerTools\]/a baseurl=https://mirror.rackspace.com/centos-vault/8.5.2111/PowerTools/$basearch/os' /etc/yum.repos.d/CentOS-PowerTools.repo
```

Then update your system with `sudo dnf update -y --allowerasing`

After the update has finished, remove the new `.repo` files which point to a non-existent mirrorslist with:

```
sudo rm -f /etc/yum.repos.d/CentOS-Linux-*.repo
```

You're now able to use the aformentioned migration scripts to migrate your CentOS 8.5 to your desired Enterprise Linux 8.

## Want to contribute?

*   [How can I contribute to the Qubes Project?](https://www.qubes-os.org/doc/contributing/)

*   [Guidelines for Documentation Contributors](https://www.qubes-os.org/doc/doc-guidelines/)

[switch]: https://www.qubes-os.org/doc/templates/#switching
[reinstall]: https://www.qubes-os.org/doc/reinstall-template/
[uninstall]: https://www.qubes-os.org/doc/templates/#uninstalling
[Minimal TemplateVMs]: https://www.qubes-os.org/doc/templates/minimal/
[Xfce TemplateVMs]: https://www.qubes-os.org/doc/templates/xfce/
