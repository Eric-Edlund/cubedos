#
# This shell script is executed by Jenkins. It defines a "build."

# This script will exit immediately if any command returns a failing exit status.
set -e

# Make sure we have the environment we need.
export PATH=/opt/gnat/bin:/opt/spark/bin:/opt/codepeer/bin:/opt/gnatstudio/bin:$PATH

# Build the test programs. We can't run them right now because they are infinite loops.
gprbuild -P src/cubedos.gpr src/check/main_file.adb
gprbuild -P src/cubedos.gpr src/check/main_time.adb
gprbuild -P src/cubedos.gpr src/check/main_message_manager.adb

# Build the sample programs.
gprbuild -P samples/Echo/echo.gpr samples/Echo/main.adb
gprbuild -P samples/PubSub/pubsub.gpr samples/PubSub/main.adb
#gprbuild -P samples/STM32F4/stmdemo.gpr samples/STM32F4/main.adb

# TODO: Do a style check using GNATcheck.
# TODO: Get the GNATtest stuff working so we can build/execute it here.

# Build the API documentation. This has to be done after a successful build.
gnatdoc -P src/cubedos.gpr --output=html

# Build the main documentation.
cd doc
pdflatex -file-line-error -halt-on-error CubedOS.tex
bibtex CubedOS
pdflatex -file-line-error -halt-on-error CubedOS.tex > /dev/null
pdflatex -file-line-error -halt-on-error CubedOS.tex > /dev/null
cd ..

# Do SPARK analysis.
gnatprove -P src/cubedos.gpr --level=2 --mode=silver -j2

# Do CodePeer analysis.
codepeer -P src/cubedos.gpr -level 2 -j2 -output-msg -quiet

# TODO: Copy documentation to the web site for public review.