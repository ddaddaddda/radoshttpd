#!/bin/bash
PACKAGENAME=wuzei
echo Building RPMs..
GITROOT=`git rev-parse --show-toplevel`
cd $GITROOT
VER=0.1
REL=`git rev-parse --short HEAD`git
RPMTOPDIR=$GITROOT/rpm-build
echo "Ver: $VER, Release: $REL"

# Create tarball
mkdir -p $RPMTOPDIR/{SOURCES,SPECS}
git archive --format=tar --prefix=${PACKAGENAME}-${VER}-${REL}/ HEAD | gzip -c > $RPMTOPDIR/SOURCES/${PACKAGENAME}-${VER}-${REL}.tar.gz
# Convert git log to RPM's ChangeLog format (shown with rpm -qp --changelog <rpm file>)
sed -e "s/%{ver}/$VER/" -e "s/%{rel}/$REL/" $GITROOT/package/${PACKAGENAME}.spec > $RPMTOPDIR/SPECS/${PACKAGENAME}.spec
git log --format="* %cd %aN%n- (%h) %s%d%n" --date=local | sed -r 's/[0-9]+:[0-9]+:[0-9]+ //' >> $RPMTOPDIR/SPECS/${PACKAGENAME}.spec
# Build SRC and binary RPMs
rpmbuild \
--define "_topdir $RPMTOPDIR" \
--define "_rpmdir $PWD" \
--define "_srcrpmdir $PWD" \
--define '_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm' \
-ba $RPMTOPDIR/SPECS/${PACKAGENAME}.spec &&
echo Done
rm -rf $RPMTOPDIR &
