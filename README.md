Android backup extractor
========================

Utility to extract and repack Android backups created with adb backup (ICS and newer).
For more information regarding backup process visit:
- <http://www.thesuperusersguide.com/adb-backup--restore.html>
- <http://forum.xda-developers.com/showthread.php?t=1420351>

Java implementation is largely based on BackupManagerService.java from AOSP. 

Folder perl contains implementation in Perl. For details info refer to <http://forum.xda-developers.com/showthread.php?p=27840175>


Description and scope:
- Android backup extractor is an application written in Java that can extract and create android adb backups. 
- The adb backups (usually with .ab extension) can be password protected or not.
- The adb backups are extracted to tar format, and are created from the tar format as well.
- In order to create a valid tar archive to later pack it in adb format, such tar has to contain the files and folders in a particular order, not necessarily alphabetical like tar does by default. Such order may be listed in Android's documentation or source code files. The easiest way is to repackage a tar archive from an already existing one; for example a subpart of an archive, and repackage it following the same order as files are listed in the original. If we don't have the original archive, we have to guess out the order.

Considerations:
- The files and folders inside the tar archive must be in some specific order or adb will fail to restore.
- The tar archives may be extracted and created on filesystems that respect tar's content's permissions, although seems to work in any case.
- Directories inside tar archives must not contain trailing slashes. Since GNU tar doesn't have this option, the use of star or pax is necessary. For ubuntu there is star_1.5final-2ubuntu2_i386.deb
- Java 7 is required.
- If the backup is password protected it must be specified in the command line.
- When restoring a backup on the android device, some files are only restored if the application is installed first. Some applications are never stored on backups due to application policies, remaining its data and settings at most. If you want a full backup use Clockworkmod or TWRP instead of ADB.
- Some applications or its data can't be restored on a different device, because may be set specific for the device's id.
- Android debugging bridge is very slow (about 1 MBps), and that doesn't depend on the device or computer, so consider that backing and restoring may take a long time.

Requirements for compilation:
- Bouncy Castle java release "JCE with provider and lightweight API"
  <http://www.bouncycastle.org/latest_releases.html>
- Oracle Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files 7
  <http://www.oracle.com/technetwork/java/javase/downloads/jce-7-download-432124.html>
- Java Standard Edition version 7
- IDE Eclipse (optional but recommended)

Usage: 
Drop the latest Bouncy Castle jar in lib/, import in Eclipse and adjust 
build path if necessary. Use the abe.sh script to start the utility:
- ```unpack:	abe.sh unpack <backup.ab> <backup.tar> [password]```
- ```pack:	abe.sh pack <backup.tar> <backup.ab> [password]```

If you don't specify a password the backup archive won't be encrypted but only compressed. 

Alternatively: 
Use the bundled Ant script to create an all-in-one jar and run with (you still need to put the Bouncy Castle jar in lib/): 
```java -jar abe.jar pack|unpack [parameters as above]```

More details about the backup format and the tool implementation in the 
associated blog post <http://nelenkov.blogspot.com/2012/06/unpacking-android-backups.html>

If you are working with password encrypted adb backups in US, you need additonal components from
<http://www.oracle.com/technetwork/java/javase/downloads/jce-7-download-432124.html>.
Put ```local_policy.jar``` and ````US_export_policy.jar```in the lib/security folder of all your Java SE 7 installations, for example:
- Windows:
    - ```C:\Program Files\Java\jdk1.7.0_09\jre\lib\security\```
    - ```C:\Program Files\Java\jre7\lib\security\```
    - ```C:\Program Files (x86)\Java\jdk1.7.0_07\jre\lib\security\```
    - ```C:\Program Files (x86)\Java\jre7\lib\security\```
- Linux: ```/usr/local/jdk1.7/jre/lib/security/```
- BSD: ```/usr/lib/jvm/java-7-openjdk-*/jre/lib/security/```
- MAC OS: ```/Library/Java/JavaVirtualMachines/jdk1.7.0_09.jdk/Contents/Home/jre/lib/security/```
- Note: Won't work if you supply them with the application, you must have them installed onto your system.

Here is an example on how to make a custom adb backup from a complete one, for the game Grand Theft Auto III from Rockstar Games, installed on the Nexus 7.
- Unpack the original adb backup: ```java -jar abe.jar unpack nexus7.ab nexus7.tar <password>```
- Extract the contents of the tar archive.
  This should be done on a filesystem where the permissions
  of the files inside the tar are preserved, for example using linux,
  mac or bsd. Up to two folders may appear, apps and shared: ```tar -xvf nexus7.tar```
- Make a list of all the contents of the original archive in the order they are archived: ``` tar -tf nexus7.tar > nexus7.list```
- Create a new list only with the files and folders you want, in proper order.
  For example for the GTA 3 (you can try savegames instead of all data): ```cat nexus7.list | grep com.rockstar.gta3 > gta3.list```
- Create the new tar archive. The directories stored on tar mustn't contain trailing slashes, so I use star instead of tar.
  Pax works also: ```cat gta3.list | pax -wd > gta3.tar``` or ```star -c -v -f gta3.tar -no-dirslash list=gta3.list```
- Create the adb backup from the tar archive. Password is optional: ```java -jar abe.jar pack gta3.tar gta3.ab <password>```
- Note: if the backup is not encrypted zlib, can be used instead for both unpack and pack the ab archive:
    - Quick unpacking: ```dd if=nexus7.ab bs=24 skip=1 | openssl zlib -d > nexus7.tar```
    - Quick packing: ```dd if=nexus7.ab bs=24 count=1 of=gta3.ab ; openssl zlib -in gta3.tar >> gta3.ab```

Authors:
- Nikolay Elenkov (Reference Java implementation and initial documentation)
- Jeffrey J. Kosowsky (Perl implementation and documentation)

Contributors:
- Jan Peter Stotz (Ant support)
- Eugene San (Java6 support and some enhancements)
