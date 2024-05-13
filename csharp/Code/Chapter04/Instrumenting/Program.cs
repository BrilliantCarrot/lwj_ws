using static System.Console;
using System.Diagnostics;

// 프로젝트 폴더에 텍스트 파일을 생성한다.
Trace.Listeners.Add(new TextWriterTraceListener(
    File.CreateText(Path.Combine(Environment.GetFolderPath(
        Environment.SpecialFolder.DesktopDirectory), "log.txt"))));
// 텍스트 작성기는 버퍼링되므로 이 옵션을 설정해서
// 쓰기 작업 후 모든 수신기가 Flush()를 호출하게 한다.
Trace.AutoFlush = true;

Debug.WriteLine("Debug says, I am watching!");
Trace.WriteLine("Trace says, I am watching!");
