# frozen_string_literal: true

# Lets posts be written with KaTeX-style math:
#   inline  : $ ... $
#   display : $$ ... $$  (on its own line, or spanning several lines)
#
# kramdown only understands $$ ... $$, and it treats a $$ block as display math
# only when it stands alone between blank lines. Before each post is rendered,
# this hook rewrites the markdown into that form:
#   - every display block gets blank lines around it (blank lines inside are removed)
#   - every inline $x$ becomes $$x$$
# Code blocks and `code spans` are left untouched.

module MathDollar
  FENCE = /\A\s*(`{3,}|~{3,})/.freeze
  PREFIX = /\A((?:[ \t]*>)*[ \t]*)/.freeze
  LIST_MARKER = /\A([-*+]|\d+\.)[ \t]+/.freeze

  module_function

  def convert(text)
    lines = text.split("\n", -1)
    out = []
    fence = nil
    i = 0
    while i < lines.length
      line = lines[i]

      if fence
        out << line
        fence = nil if line.strip.start_with?(fence)
        i += 1
        next
      end

      if (m = FENCE.match(line))
        fence = m[1]
        out << line
        i += 1
        next
      end

      prefix = line[PREFIX, 1]
      body = line[prefix.length..]

      if display_start?(body)
        i = emit_display(lines, i, prefix, out)
        next
      end

      out << prefix + convert_inline_line(body, block_start?(out, prefix))
      i += 1
    end
    out.join("\n")
  end

  # A line that opens display math: starts with $$ and is not "$$a$$ text $$b$$".
  def display_start?(body)
    s = body.strip
    return false unless s.start_with?('$$')
    return true if s == '$$'

    rest = s[2..]
    close = rest.index('$$')
    return true if close.nil? # opens a multi-line block

    # single line: $$ ... $$ with nothing after the closing $$
    rest[(close + 2)..].strip.empty?
  end

  def emit_display(lines, i, prefix, out)
    blank = prefix.rstrip
    content = []
    first = lines[i][prefix.length..].strip[2..]

    if (close = first.index('$$'))
      content << first[0...close]
      i += 1
    else
      content << first
      i += 1
      while i < lines.length
        raw = lines[i]
        b = raw.start_with?(prefix) ? raw[prefix.length..] : raw.sub(PREFIX, '')
        if (close = b.index('$$'))
          content << b[0...close]
          i += 1
          break
        end
        content << b
        i += 1
      end
    end

    content = content.map(&:rstrip).reject { |c| c.strip.empty? }

    out << blank unless out.empty? || out.last.strip == blank.strip
    out << "#{prefix}$$"
    content.each { |c| out << "#{prefix}#{c}" }
    out << "#{prefix}$$"
    out << blank if i < lines.length && lines[i].strip != blank.strip
    i
  end

  # true when the next line starts a new block (so a leading $$ could be read as display math)
  def block_start?(out, prefix)
    out.empty? || out.last.strip == prefix.rstrip.strip
  end

  def convert_inline_line(body, at_block_start)
    marker = body[LIST_MARKER, 0] || ''
    rest = body[marker.length..]
    converted = convert_inline(rest)
    # a line holding nothing but $$x$$ would become display math; "\$$x$$" keeps it inline
    if converted.match?(/\A\$\$(?:(?!\$\$).)+\$\$\s*\z/) && (at_block_start || !marker.empty?)
      converted = "\\#{converted}"
    end
    marker + converted
  end

  # $x$ -> $$x$$ outside `code spans`; existing $$x$$ and \$ are kept.
  def convert_inline(text)
    result = +''
    pos = 0
    while pos < text.length
      ch = text[pos]
      if ch == '`'
        ticks = text[pos..][/\A`+/]
        close = text.index(ticks, pos + ticks.length)
        if close
          result << text[pos...(close + ticks.length)]
          pos = close + ticks.length
          next
        end
        result << ticks
        pos += ticks.length
      elsif ch == '\\' && text[pos + 1] == '$'
        result << '\\$'
        pos += 2
      elsif text[pos, 2] == '$$'
        close = text.index('$$', pos + 2)
        if close
          result << "$$#{fix_pipes(text[(pos + 2)...close])}$$"
          pos = close + 2
        else
          result << '$$'
          pos += 2
        end
      elsif ch == '$'
        close = find_inline_close(text, pos + 1)
        if close
          result << "$$#{fix_pipes(text[(pos + 1)...close])}$$"
          pos = close + 1
        else
          result << '$'
          pos += 1
        end
      else
        result << ch
        pos += 1
      end
    end
    result
  end

  # kramdown reads any line with a bare | as a table row, so | inside inline math becomes \vert
  def fix_pipes(math)
    math.gsub(/(?<!\\)\|/) { '\vert ' }
  end

  def find_inline_close(text, from)
    j = from
    while j < text.length
      if text[j] == '\\'
        j += 2
        next
      end
      return j if text[j] == '$' && text[j + 1] != '$'
      return nil if text[j] == '$' # hit a $$
      j += 1
    end
    nil
  end
end

if defined?(Jekyll::Hooks)
  Jekyll::Hooks.register :posts, :pre_render do |post|
    post.content = MathDollar.convert(post.content) if post.data['math']
  end
end
