// import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uidev/app/Item.dart';
import 'package:uidev/app/Work.dart';
import 'package:uidev/app/KeyResult.dart';
import 'package:uidev/app/Task.dart';

void main() {
  Work project = new Work("SC2021", "Complete the app and win the contest", 
                          DateTime(2021,3,31), 
                          "App keeps track user's working progress using OKR system");
  KeyResult kr1 = new KeyResult("Interview 15 people to get an overview of problem",
                                DateTime(2021, 2, 5));
  KeyResult kr2 = new KeyResult("Sketch the app UI and create prototype", DateTime(2021, 2, 15));
  KeyResult kr3 = new KeyResult("Complete the app and answer the Google's questions",
                                DateTime(2021, 3, 31));
  Task task1 = new Task(2, "List all potential user personas");
  Task task2 = new Task(1, "Meet interviewees suitable with the listed personas");
  Task task3 = new Task(3, "Meeting with team to design the raw UI of the app");
  Task task4 = new Task(2, "Using MarvelApp/Figma to prototype the UI");
  Task task5 = new Task(1, "Test the prototype with potential interviewees");
  Task task6 = new Task(1, "Design Class Entities for backend");
  Task task7 = new Task(2, "Answer Google's questions and analyze what missed or achieved");
  group("Work", () {
    test("Work created is not Done yet", () {
      expect(project.isDone, false);
    });
    test("Work without KR can be marked as Done", () {
      project.markDone();
      expect(project.isDone, true);
    });
    test("Not allow to add Key Result with later deadline to Work", () {
      KeyResult late_kr = new KeyResult("A useless Key Result", DateTime(2021, 5, 1));
      project.addKeyResult(late_kr);
      expect(project.allKeyResult.length, 0);
    });
    test("Test addKeyResult()", () {
      project.addKeyResult(kr1);
      expect(project.allKeyResult.length, 1);
    });
    test("Test addManyKeyResults", () {
      project.addManyKeyResults([kr2, kr3]);
      expect(project.allKeyResult.length, 3);
    });
  });
}