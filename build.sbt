import org.typelevel.scalacoptions.*

Global / onChangedBuildSource := ReloadOnSourceChanges

lazy val scala3 = "3.6.2"

ThisBuild /git.useGitDescribe := true

ThisBuild / scalaVersion       := scala3
ThisBuild / crossScalaVersions := Seq(scala3)

ThisBuild / organization      := "io.github.ramytanios"
ThisBuild / organizationName  := "ramytanios"

ThisBuild / semanticdbEnabled := true
ThisBuild / semanticdbVersion := scalafixSemanticdb.revision

ThisBuild / tpolecatExcludeOptions := Set(ScalacOption("-Xfatal-warnings", _ => true))

lazy val V = new {
  val cats          = "2.12.0"
  val catsEffect    = "3.5.4"
  val decline       = "2.5.0"
}

lazy val root = project.in(file("."))
  .aggregate(app)
  .settings(publish / skip := true)
  .enablePlugins(GitVersioning)

lazy val app = project
  .in(file("app"))
  .enablePlugins(GitVersioning)
  .settings(
    name               := "app",
    libraryDependencies ++=
      Seq(
        "org.typelevel"         %% "cats-core"                 % V.cats,
        "org.typelevel"         %% "cats-effect"               % V.catsEffect,
        "org.typelevel"         %% "cats-effect-std"           % V.catsEffect,
        "com.monovore"          %% "decline"                   % V.decline,
        "com.monovore"          %% "decline-effect"            % V.decline
      )
  )

