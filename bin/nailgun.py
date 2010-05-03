#!/usr/bin/env python
'''Runs the flex compiler jars in a nailgun server'''
import os
projdir = "." #"/".join(__file__.split("/")[:-2])
flexlibdir = projdir + "/lib/flex_sdk/lib"
path = [projdir + '/extlibs/java/nailgun.jar']
path.extend(["%s/%s" % (flexlibdir, fn) for fn in os.listdir(flexlibdir)])
os.system("java -server -cp %s com.martiansoftware.nailgun.NGServer" % ":".join(path))
