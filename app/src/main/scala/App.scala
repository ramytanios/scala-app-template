package app

import cats.effect.*
import com.monovore.decline.*
import com.monovore.decline.effect.CommandIOApp

object App
    extends CommandIOApp(
      "dummy-app",
      "A dummy app",
      version = BuildInfo.version
    ):

  override def main: Opts[IO[ExitCode]] =
    Opts
      .option[String]("message", "Message to print").map: message =>
        IO.println(message).as(ExitCode.Success)
