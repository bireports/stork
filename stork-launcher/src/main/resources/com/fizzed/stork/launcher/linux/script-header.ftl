#!/usr/bin/env sh

#
# Shell script to launch Java app ${config.name}
#
# Description: ${config.shortDescription}
#
# Auto generated via Stork Launcher v${version} made by Fizzed, Inc.
#  Web: http://fizzed.com
#  Twitter: http://twitter.com/fizzed_inc
#  Github: https://github.com/fizzed/stork
#

#
# constants
#

NAME="${config.name}"
TYPE="${config.type}"
MAIN_CLASS="${config.mainClass}"
[ -z "$WORKING_DIR_MODE" ] && WORKING_DIR_MODE="${config.workingDirMode}"
[ -z "$MIN_JAVA_VERSION" ] && MIN_JAVA_VERSION="${config.minJavaVersion}"
[ -z "$MAX_JAVA_VERSION" ] && MAX_JAVA_VERSION="${config.maxJavaVersion!""}"
[ -z "$SYMLINK_JAVA" ] && SYMLINK_JAVA="${config.symlinkJava?string("1", "0")}"
[ -z "$INCLUDE_JAVA_XRS" ] && INCLUDE_JAVA_XRS="${config.includeJavaXrs?string("1", "0")}"

#
# working directory
#

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ] ; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# save current working directory
INITIAL_WORKING_DIR="`pwd`"

# change working directory to app home
PRGDIR=$(dirname "$PRG")
cd "$PRGDIR/.."

# application home is now current directory
APP_HOME="`pwd`"

# revert to initial working directory?
if [ "$WORKING_DIR_MODE" = "RETAIN" ]; then
  cd "$INITIAL_WORKING_DIR"
fi

#
# settings
# either change default in here OR just pass in as environment variable to
# override the default value here
# e.g. RUN_DIR=/tmp bin/$NAME
#

# if empty pid file will be created in <run_dir>/<app_name>.pid
# provide full path if you want to override
[ -z "$PID_FILE" ] && PID_FILE=""

# min and max mem (in MB); leave empty for java defaults
[ -z "$JAVA_MIN_MEM" ] && JAVA_MIN_MEM="${(config.minJavaMemory?c)!""}"
[ -z "$JAVA_MAX_MEM" ] && JAVA_MAX_MEM="${(config.maxJavaMemory?c)!""}"

# min and max mem as a percent of system memory
# they have priority over JAVA_MIN_MEM and JAVA_MAX_MEM if set
[ -z "$JAVA_MIN_MEM_PCT" ] && JAVA_MIN_MEM_PCT="${(config.minJavaMemoryPct?c)!""}"
[ -z "$JAVA_MAX_MEM_PCT" ] && JAVA_MAX_MEM_PCT="${(config.maxJavaMemoryPct?c)!""}"

# application run dir (e.g. for pid file)
[ -z "$RUN_DIR" ] && RUN_DIR="${config.runDir!""}"

# application log dir (e.g. for [name.out] file)
[ -z "$LOG_DIR" ] && LOG_DIR="${config.logDir!""}"

[ -z "$LAUNCHER_DEBUG" ] && LAUNCHER_DEBUG="0"

#
# Variables
#

[ -z "$APP_ARGS" ] && APP_ARGS="${config.appArgs}"
[ -z "$EXTRA_APP_ARGS" ] && EXTRA_APP_ARGS="${config.extraAppArgs}"
[ -z "$JAVA_ARGS" ] && JAVA_ARGS="${config.javaArgs}"
[ -z "$EXTRA_JAVA_ARGS" ] && EXTRA_JAVA_ARGS="${config.extraJavaArgs}"
[ -z "$LIB_DIR" ] && LIB_DIR="${config.libDir}"
[ -z "$SKIP_PID_CHECK" ] && SKIP_PID_CHECK="0"
<#if (config.type == "DAEMON")>
[ -z "$DAEMON_MIN_LIFETIME" ] && DAEMON_MIN_LIFETIME="${config.daemonMinLifetime!""}"
</#if>


isAbsolutePath()
{
    local p="$1"
    if [ "$(echo $p | cut -c 1)" = "/" ]; then
        return 0
    else
        return 1
    fi
}


#
# is run directory absolute or relative to app home?
#
if [ `isAbsolutePath "$RUN_DIR"` ]; then
    # absolute path
    APP_RUN_DIR="$RUN_DIR"
    APP_RUN_DIR_DEBUG="$RUN_DIR"
    APP_RUN_DIR_ABS="$RUN_DIR"
else
    if [ "$WORKING_DIR_MODE" = "RETAIN" ]; then
        # relative path to app home (but use absolute version)
        APP_RUN_DIR="$APP_HOME/$RUN_DIR"
    else
        # relative path to app home (use relative version)
        APP_RUN_DIR="$RUN_DIR"
    fi
    APP_RUN_DIR_DEBUG="<app_home>/$RUN_DIR"
    APP_RUN_DIR_ABS="$APP_HOME/$RUN_DIR"
fi


#
# is log directory absolute or relative to app home?
#
if [ `isAbsolutePath "$LOG_DIR"` ]; then
    # absolute path
    APP_LOG_DIR="$LOG_DIR"
    APP_LOG_DIR_DEBUG="$LOG_DIR"
    APP_LOG_DIR_ABS="$LOG_DIR"
else
    if [ $WORKING_DIR_MODE = "RETAIN" ]; then
        # relative path to app home (but use absolute version)
        APP_LOG_DIR="$APP_HOME/$LOG_DIR"
    else
        # relative path to app home (use relative version)
        APP_LOG_DIR="$LOG_DIR"
    fi
    APP_LOG_DIR_DEBUG="<app_home>/$LOG_DIR"
    APP_LOG_DIR_ABS="$APP_HOME/$LOG_DIR"
fi


#
# pid handling
#
if [ ! -z $PID_FILE ]; then
    APP_PID_FILE="$PID_FILE"
    APP_PID_FILE_DEBUG="$PID_FILE"
else
    APP_PID_FILE="$APP_RUN_DIR/$NAME.pid"
    APP_PID_FILE_DEBUG="$APP_RUN_DIR_DEBUG/$NAME.pid"
fi


#
# do we need verify that the run directory is writable?
#

# will the run directory be used for something?
if [ "$TYPE" = "DAEMON" ] || [ "$SYMLINK_JAVA" = "1" ]; then
    if [ ! -d "$APP_RUN_DIR" ]; then
        mkdir -p "$APP_RUN_DIR" 2>/dev/null
        if [ ! -d "$APP_RUN_DIR" ]; then
            echo "Unable to create run dir: $APP_RUN_DIR_ABS (check permissions; is user `whoami` owner?)"
            exit 1
        fi
    fi
    if [ ! -w "$APP_RUN_DIR" ]; then
        echo "Unable to write files in run dir: $APP_RUN_DIR_ABS (check permissions; is user `whoami` owner?)"
        exit 1
    fi
fi
