using Images
import VideoIO

# 字符像素
const pixels = raw"$#@&%ZYXWVUTSRQPONMLKJIHGFEDCBA098765432?][}{/\\)(><zyxwvutsrqponmlkjihgfedcba*+1!:`'-,. "


function video2imgs(video_name::String, img_size::Tuple; framerate=8)
    imgs = Array{Gray{Normed{UInt8,8}},2}[]
    f = VideoIO.openvideo(video_name)
    t = 0.0
    step = 1/framerate
    try
        while !eof(f)
            img = imresize(read(f), img_size)  # 读取 image 并 resize
            push!(imgs, Gray.(img))   # 转换成灰度图，然后 push 到 imgs 里边
            seek(f, t += step)  # t 的单位是秒
        end
    catch EOFError  # 读取到末尾
        # do nothing
    end

    imgs
end


function img2ascii(img::Array{Gray{Normed{UInt8,8}},2})
    res = String[]
    for row in 1:height(img)
        line = ""
        for col in 1:width(img)
            percent = img[row, col]
            index = ceil(Int, percent.val * length(pixels)) + 1  # 计算出灰度对应的字符索引

            # 添加字符像素（最后面加一个空格，是因为命令行有行距却没几乎有字符间距，用空格当间距）
            line *= pixels[index > length(pixels) ? length(pixels)-1 : index] * " "
        end
        push!(res, line)
    end
    join(res, "\n")
end


function play_ascii(ascii_pics::Array{String, 1}, framerate=1/8)
    for frame in ascii_pics
        print(frame)  # 输出
        sleep(framerate)
        run(Cmd(`clear`))  # 清屏
    end
end


function play_audio(video_name::String)
    # 异步播放
    @async run(Cmd(`mpv --no-video $video_name`))
end


# 转换成字符动画
videoname = "BadApple.mp4"
imgs = video2imgs(videoname, (48, 64))
ascii_pics = img2ascii.(imgs)

# 播放
play_audio(videoname)
play_ascii(ascii_pics)
