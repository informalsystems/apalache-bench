import org.apache.commons.io.FileUtils
import java.text.SimpleDateFormat
import scala.sys.process.Process
import java.util.Date
import org.apache.commons.io.FilenameUtils

ThisBuild / version := "0.0.1"
ThisBuild / sbtVersion := "1.6.1"
ThisBuild / scalaVersion := "2.13.6"
ThisBuild / organization := "systems.informal"

import BenchExecDsl._

lazy val root = (project in file("."))
  .enablePlugins(Apalache)

lazy val performance = (project in file("performance"))
  .settings(
    benchmarks +=
      Bench.Suite(
        name = "001indinv-apalache",
        runs = Seq(
          // Bench.Runs(
          //   "APABakery",
          //   timelimit = "1h",
          //   cmds = Seq(
          //     Cmd(
          //       "init with Init",
          //       Opt("check"),
          //       Opt("--init", "Init"),
          //       Opt("--inv", "Inv"),
          //       Opt("--length", 0),
          //     ),
          //     Cmd(
          //       "init with Inv",
          //       Opt("check"),
          //       Opt("--init", "Inv"),
          //       Opt("--inv", "Inv"),
          //       Opt("--length", 1),
          //     ),
          //   ),
          //   tasks = Seq(Tasks("APABakery", "Bakery-Boulangerie/APABakery.tla")),
          // ),
          // Bench.Runs(
          //   "APAEWD840",
          //   timelimit = "3h",
          //   cmds = Seq(
          //     Cmd(
          //       "without init",
          //       Opt("check"),
          //       Opt("--inv", "InvAndTypeOK"),
          //       Opt("--length", 0),
          //       Opt("--cinit", "ConstInit10"),
          //     ),
          //     Cmd(
          //       "with init",
          //       Opt("check"),
          //       Opt("--init", "InvAndTypeOK"),
          //       Opt("--inv", "InvAndTypeOK"),
          //       Opt("--length", 1),
          //       Opt("--cinit", "ConstInit10"),
          //     ),
          //   ),
          //   tasks = Seq(Tasks("APAEWD840.tla", "ewd840/APAEWD840.tla")),
          // ),
          // Bench.Runs(
          //   "APAbcastByz",
          //   timelimit = "3h",
          //   cmds = Seq(
          //     Cmd(
          //       "init with InitNoBcast",
          //       Opt("check"),
          //       Opt("--init", "IndInv_Unforg_NoBcast"),
          //       Opt("--inv", "InitNoBcast"),
          //       Opt("--length", 0),
          //       Opt("--cinit", "ConstInit4"),
          //     ),
          //     Cmd(
          //       "with init IndInv_Unforg_NoBcast",
          //       Opt("check"),
          //       Opt("--init", "IndInv_Unforg_NoBcast"),
          //       Opt("--inv", "IndInv_Unforg_NoBcast"),
          //       Opt("--length", 1),
          //       Opt("--cinit", "ConstInit4"),
          //     ),
          //   ),
          //   tasks = Seq(Tasks("APAbcastByz.tla", "bcastByz/APAbcastByz.tla")),
          // ),
          Bench.Runs(
            "APATwoPhase",
            timelimit = "23h",
            cmds = Seq(
              Cmd(
                "no init",
                Opt("check"),
                Opt("--inv", "Inv"),
                Opt("--length", 0),
                Opt("--cinit", "ConstInit7"),
              ),
              Cmd(
                "init with InitInv",
                Opt("check"),
                Opt("--init", "InitInv"),
                Opt("--inv", "Inv"),
                Opt("--length", 1),
                Opt("--cinit", "ConstInit7"),
              ),
            ),
            tasks = Seq(Tasks("APAbcastByz.tla", "two-phase/APATwoPhase.tla")),
          )
        ),
      )
  )
