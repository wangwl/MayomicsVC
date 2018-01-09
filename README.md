1 Objective
===========

Recreate GenomeGPS in Cromwell/WDL instead of Bash/Perl.


2 Design principles
===================

2.1 Modularity
--------------

This workflow is modular by design, with each bioinformatics task in its own module. 
WDL ought to make this easy by defining "tasks" and "workflows". Tasks in our case 
will wrap individual bioinformatics steps that correspond to the blocks in the diagram 
below. Tasks can be run individually and also strung together into workflows.

Variant calling workflow is complex, so we break it up into smaller blocks that are 
easier to develop and maintain. Blocks can be run individually and also called sequentially 
to execute part or full workflow. 

_Reasons for modular design:_
* flexibility: can execute any part of the workflow; 
    * useful for testing or after failure
    * can swap tools in and out for every task based on user's choice
* optimal resource utilization: can specify number of nodes, walltime etc that is best for every stage
* maintainability: can edit modules without breaking the rest of the workflow 



2.1 Data parallelism and scalability
------------------------------------


2.2 Real-time logging and monitoring
------------------------------------



2.3 Fault tolerance
-------------------

* Must be robust against hardware/software/data failure
    * user option on whether to fail or continue the whole workflow when something goes wrong with one of the sample
    * produce logs on failure; capture exit codes; write to FAIL log file; email analyst 
    * check everything before workflow actually runs: 
       * check that all the sample files exist and have nonzero size 
       * check that all executables exist
       * for each workflow module at runtime, check that output was actualy produced and has nonzero size
       * perform QC on each output file, write results into log, give user option to continue anyway if QC is failed


2.4 Data provenance tracking
----------------------------




2.5 Portability
---------------



2.6 Development and test automation 
-----------------------------------


* Unit testing
    * Must have tests designed to succeed and designed to fail to ensure that failure mechanisms work



3 Workflow architecture
=======================


* Reconstruct from GenomeGPS file structure, highlight which parts will be done by us and in what order.
* Mayo and UIUC will have division of labor among the modules - highlight those too, in different color


[have workflow diagram here]


Cromwell/WDL is workflow definition language that is designed from the ground up as a human-readable and -writable way to express tasks and workflows. The workflows are written are .wdl scripts and they are executed using cromwell execution engine. The wdl scripts have a task block where the task to be performed is written. For eg. To write a task which performs BWA Mem, the commands are written inside the task block. A wdl script can have more than one task defined in a script. All the tasks are called within a block called the Workflow block. 

The /src folder contains three sub folders namely /Tasks, /TestTasks and /TestWorkflow. The /Tasks folder contains the individual tasks of the Alignment block. The files are named as per the function that they perform. The scripts inside the /TestTasks folder are used for testing each step of the workflow seperately. For eg. TestBWA_Sam.wdl is script that includes the Bwa_Sam.wdl as a task to execute BWA Mem. The /TestBlock folder has scripts that include all the steps of the workflow as individual modules and performs Alignment for a given set of samples. The TestAlickBlock.wdl imports Bwa_Sam.wdl, Novosort.wdl and PicardMD.wdl to execute Alignment for a set of samples.

The diagram below shows how the individual steps in the Alignemnt Block are written. These steps are part of the Alignment Block cand can be executed as individual tasks as well. 



![Image of Folder Structure](https://github.com/ncsa/Genomics_MGC_GenomeGPS_CromwelWDL/blob/dev/media/Folder_Design.svg)



3.1 pendencies
--------------

Grab from GenomeGPS documentation, highlight which parts we are doing in what order.



4 Design
========


command <<< >>>

String dollar = "$"

tasks of tasks

workflows or workflows



4.1 Naming conventions
----------------------

gg




5 Testing
=========




6 To-Dos
========

* As of Oct 24, 2017: Ram will work only on the bwa-mem module, to implement fully the template that could be used for other modules
    * multiple samples in parallel
    * all paths and parameters coded in runfile
    * loggery, user notification
    * error capture
    * checking inputs and executables
    * checking outputs
    * QC on input FASTQ
    * QC on outputs


7 Output Folder Structure
=============================

Cromwell creates a nested output folder structure, one for each tool, and for each sample inside:

* After every execution of Cromwell tool, a folder named "cromwell-executions" is created in the directory from where the cromwell execution engine is run.
* Inside the "cromwell-executions" folder, a sub folder is created and its name corresponds to the name of the workflow specified in the .wdl file. For example if the name of the workflow in the .wdl file is BWA_Mem_Run then a sub folder is created with the same name.
* After the workflow has successfully executed an ID for the execution is created and this ID is unique for each run. In the example below "97cbc5de-ff36-4912-aa04-395b08702c85" is an unique ID name. 

```
  |-cromwell-executions
  |  |-BWA_Mem_Run
  |  |  |-97cbc5de-ff36-4912-aa04-395b08702c85
```

* Inside each folder with the unique ID name there are sub folders that represent the various tasks defined in the .wdl file.
* The various tasks have a "call" prefix to it as shown below. 

```
  |
  |-call-Samtools
  |-call-BWA-MEM
```

* Inside the individual task, every sample has an individual folder created for it.  "shard-0" in the example below represents the Sample 1 and "shard-1" represents Sample 2 and so on.

```
  |-call-Samtools
  |  |-shard-0
  |  |-shard-1
  |  |-shard-2
```
* Every shard folder contains an execution folder as seen below.

```
  |-shard-0
  |  |-execution
```

* "glob-" folder is present inside every execution folder and it is inside this folder that the output of our program exists. The example below shows the where the output of our program resides at.

```
  |-execution
  |  |-glob-8fbfe7a84f921347caf0a4408578e296
  |  |  | -aligned.bam
```

* The example below shows how the entire directory tree and how the folders are created every time the cromwell excution engine executes a wdl program.

```
  |
  |-call-Samtools
  |  |-shard-2
  |  |  |-inputs
  |  |  |  |-projects
  |  |  |  |  |-mgc
  |  |  |  |  |  |-Project_1
  |  |  |  |  |  |  |-ram
  |  |  |  |  |  |  |  |-CromwellWDL
  |  |  |  |  |  |  |  |  |-MultiSampleMultiStepVC
  |  |  |  |  |  |  |  |  |  |-cromwell-executions
  |  |  |  |  |  |  |  |  |  |  |-BWA_Mem_Run
  |  |  |  |  |  |  |  |  |  |  |  |-97cbc5de-ff36-4912-aa04-395b08702c85
  |  |  |  |  |  |  |  |  |  |  |  |  |-call-BWA_Mem
  |  |  |  |  |  |  |  |  |  |  |  |  |  |-shard-2
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |-execution
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |-glob-8fbfe7a84f921347caf0a4408578e296
  |  |  |-execution
  |  |  |  |-tmp.Jh4vIo
  |  |  |  |-glob-e04fb83eeaea0b4b8fdde6282d30506c
  |  |-shard-0
  |  |  |-inputs
  |  |  |  |-projects
  |  |  |  |  |-mgc
  |  |  |  |  |  |-Project_1
  |  |  |  |  |  |  |-ram
  |  |  |  |  |  |  |  |-CromwellWDL
  |  |  |  |  |  |  |  |  |-MultiSampleMultiStepVC
  |  |  |  |  |  |  |  |  |  |-cromwell-executions
  |  |  |  |  |  |  |  |  |  |  |-BWA_Mem_Run
  |  |  |  |  |  |  |  |  |  |  |  |-97cbc5de-ff36-4912-aa04-395b08702c85
  |  |  |  |  |  |  |  |  |  |  |  |  |-call-BWA_Mem
  |  |  |  |  |  |  |  |  |  |  |  |  |  |-shard-0
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |-execution
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |-glob-e2984cba736e7acdf7c0536378232fca
  |  |  |-execution
  |  |  |  |-tmp.JOg8Ce
  |  |  |  |-glob-e04fb83eeaea0b4b8fdde6282d30506c
  |  |-shard-1
  |  |  |-inputs
  |  |  |  |-projects
  |  |  |  |  |-mgc
  |  |  |  |  |  |-Project_1
  |  |  |  |  |  |  |-ram
  |  |  |  |  |  |  |  |-CromwellWDL
  |  |  |  |  |  |  |  |  |-MultiSampleMultiStepVC
  |  |  |  |  |  |  |  |  |  |-cromwell-executions
  |  |  |  |  |  |  |  |  |  |  |-BWA_Mem_Run
  |  |  |  |  |  |  |  |  |  |  |  |-97cbc5de-ff36-4912-aa04-395b08702c85
  |  |  |  |  |  |  |  |  |  |  |  |  |-call-BWA_Mem
  |  |  |  |  |  |  |  |  |  |  |  |  |  |-shard-1
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |-execution
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |-glob-1b331778c20fad9525cbbad0d5f04486
  |  |  |-execution
  |  |  |  |-glob-e04fb83eeaea0b4b8fdde6282d30506c
  |  |  |  |-tmp.yCh857
  |-call-BWA_Mem
  |  |-shard-2
  |  |  |-inputs
  |  |  |  |-projects
  |  |  |  |  |-bioinformatics
  |  |  |  |  |  |-DataPacks
  |  |  |  |  |  |  |-human
  |  |  |  |  |  |  |  |-EllensSyntheticData
  |  |  |  |  |  |  |  |  |-WGS_chr1_5X_E0.005
  |  |  |  |  |  |  |  |  |  |-Chunks
  |  |  |  |  |  |-TestData
  |  |  |  |  |  |  |-HG19
  |  |  |  |  |  |  |  |-gatk_bundle_2.8
  |  |  |  |  |  |  |  |  |-2.8
  |  |  |  |  |  |  |  |  |  |-hg19
  |  |  |-execution
  |  |  |  |-glob-8fbfe7a84f921347caf0a4408578e296
  |  |  |  |-tmp.OWyZa0
  |  |-shard-0
  |  |  |-inputs
  |  |  |  |-projects
  |  |  |  |  |-bioinformatics
  |  |  |  |  |  |-DataPacks
  |  |  |  |  |  |  |-human
  |  |  |  |  |  |  |  |-EllensSyntheticData
  |  |  |  |  |  |  |  |  |-WGS_chr1_5X_E0.005
  |  |  |  |  |  |  |  |  |  |-Chunks
  |  |  |  |  |  |-TestData
  |  |  |  |  |  |  |-HG19
  |  |  |  |  |  |  |  |-gatk_bundle_2.8
  |  |  |  |  |  |  |  |  |-2.8
  |  |  |  |  |  |  |  |  |  |-hg19
  |  |  |-execution
  |  |  |  |-glob-e2984cba736e7acdf7c0536378232fca
  |  |  |  |-tmp.rrJiKx
  |  |-shard-1
  |  |  |-inputs
  |  |  |  |-projects
  |  |  |  |  |-bioinformatics
  |  |  |  |  |  |-DataPacks
  |  |  |  |  |  |  |-human
  |  |  |  |  |  |  |  |-EllensSyntheticData
  |  |  |  |  |  |  |  |  |-WGS_chr1_5X_E0.005
  |  |  |  |  |  |  |  |  |  |-Chunks
  |  |  |  |  |  |-TestData
  |  |  |  |  |  |  |-HG19
  |  |  |  |  |  |  |  |-gatk_bundle_2.8
  |  |  |  |  |  |  |  |  |-2.8
  |  |  |  |  |  |  |  |  |  |-hg19
  |  |  |-execution
  |  |  |  |-tmp.kbVcdk
  |  |  |  |-glob-1b331778c20fad9525cbbad0d5f04486
```

Email Notifications
====================

It's good practice to notify the analyst of failures in workflow. Failure notifications can be emailed to the analyst. Analysts can be notified at each step as and when a sample fails or a list of all the samples that have failed a step can be collected at the end of the step and that information can be emailed to the user. There are trade-offs to both these methods that have to be considered. 

If we consider the first case where notifications are sent for every sample,  the analyst will be able to figure out that something is wrong and can tend to the errors. On the other hand he/she ends up receiving numerous emails for all the samples that have failed a certain step. For eg. if there are 1000 samples that run on a workflow and if a majority of samples fail at the first step then the analyst can quickly look at the logs and figure out why the samples have failed that particular step. The disadvantage though is if 1000 samples fail a certain step then an email for each sample will be sent out flooding the analyst's inbox.

For the second case if a list of all the failed samples is made and then that information sent as an email will prevent flooding of the inbox. There is an issue with time because he/she will have to wait for the end of the step to find out which samples have failed the step which can be in order of hours depending on the step of the workflow. These are some trade-offs which have to considered while designed a workflow.



